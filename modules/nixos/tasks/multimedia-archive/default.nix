{ config, options, lib, pkgs, ... }:

let
  cfg = config.tasks.multimedia-archive;
  mountName = "/mnt/archives";
in
{
  options.tasks.multimedia-archive.enable =
    lib.mkEnableOption "multimedia archiving setup";

  config = lib.mkIf cfg.enable (
    let
      ytdlpArgs = [
        # Make a global list of successfully downloaded videos as a cache for yt-dlp.
        "--download-archive" "${config.services.yt-dlp.archivePath}/videos"

        # No overwriting of videos and related files.
        "--no-force-overwrites"

        # Embed metadata in the file.
        "--write-info-json"

        # Embed chapter markers, if possible.
        "--embed-chapters"

        # Write the subtitle file with the preferred languages.
        "--write-subs"
        "--sub-langs" "en.*,ja,ko,zh.*,fr,pt.*"

        # Write the description in a separate file.
        "--write-description"

        # The global output for all of the jobs.
        "--output" "%(uploader,artist,creator|Unknown)s/%(release_date>%F,upload_date>%F|Unknown)s-%(title)s.%(ext)s"

        # Select only the most optimal format for my usecases.
        "--format" "(webm,mkv,mp4)[height<=?1280]"

        # Prefer MKV whenever possible for video formats.
        "--merge-output-format" "mkv"

        # Don't download any videos that are originally live streams.
        "--match-filters" "!was_live"

        # Prefer Vorbis when audio-only downloads are used.
        "--audio-format" "vorbis"
        "--audio-quality" "2"
      ];
      ytdlpArchiveVariant = pkgs.writeScriptBin "yt-dlp-archive-variant" ''
        ${pkgs.yt-dlp}/bin/yt-dlp ${lib.escapeShellArgs ytdlpArgs}
      '';

      # Given an attribute set of jobs that contains a list of objects with
      # their names and URL, create an attrset suitable for declaring the
      # archiving jobs of several services for `services.yt-dlp`,
      # `services.gallery-dl`, and `services.archivebox`.
      mkJobs = { extraArgs ? [], db }:
        let
          days = [ "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday" ];
          categories = lib.zipListsWith
            (index: category: { inherit index; data = category; })
            (lib.lists.range 1 (lib.length (lib.attrValues db)))
            (lib.mapAttrsToList (name: value: { inherit name; subscriptions = value; }) db);
          jobsList = builtins.map
            (category: {
              name = category.data.name;
              value = {
                inherit extraArgs;
                urls = builtins.map (subscription: subscription.url) category.data.subscriptions;
                startAt = lib.elemAt days (lib.mod category.index (lib.length days));
                persistent = true;
              };
            })
            categories;
        in
        lib.listToAttrs jobsList;

      readJSON = jsonFile: builtins.fromJSON (builtins.readFile jsonFile);
    in
    {
      environment.systemPackages = [ ytdlpArchiveVariant ];

      sops.secrets =
        let
          getKey = key: {
            inherit key;
            sopsFile = lib.getSecret "multimedia-archive.yaml";
          };
        in
        {
          "multimedia-archive/secrets-config" = getKey "secrets-config";
        };

      fileSystems."${mountName}" = {
        device = "/dev/disk/by-uuid/6ba86a30-5fa4-41d9-8354-fa8af0f57f49";
        fsType = "btrfs";
        noCheck = true;
        options = [
          # These are btrfs-specific mount options which can found in btrfs.5
          # manual page.
          "subvol=@"
          "noatime"
          "compress=zstd:9"
          "space_cache=v2"

          # General mount options from mount.5 manual page.
          "noauto"
          "nofail"
          "user"

          # See systemd.mount.5 and systemd.automount.5 manual page for more
          # details.
          "x-systemd.automount"
          "x-systemd.idle-timeout=2"
          "x-systemd.device-timeout=2"
        ];
      };

      services.yt-dlp = {
        enable = true;
        archivePath = "${mountName}/yt-dlp-service";

        # This is applied on all jobs. It is best to be minimal as much as
        # possible for this.
        extraArgs = ytdlpArgs;

        jobs = mkJobs {
          extraArgs = [ "--playlist-end" "20" ];
          attrs = readJSON ./newpipe-db.json;
        };
      };

      services.archivebox = {
        enable = true;
        archivePath = "${mountName}/archivebox-service";
        withDependencies = true;
        webserver.enable = true;

        jobs = {
          arts = {
            urls = [
              "https://www.davidrevoy.com/feed/rss"
              "https://librearts.org/index.xml"
            ];
            startAt = "monthly";
            persistent = true;
          };

          computer = {
            urls = [
              "https://blog.mozilla.org/en/feed/"
              "https://distill.pub/rss.xml"
              "https://drewdevault.com/blog/index.xml"
              "https://fasterthanli.me/index.xml"
              "https://jvns.ca/atom.xml"
              "https://www.bytelab.codes/rss/"
              "https://www.collabora.com/feed"
              "https://www.jntrnr.com/atom.xml"
              "https://yosoygames.com.ar/wp/?feed=rss"
              "https://simblob.blogspot.com/feeds/posts/default"
            ];
            startAt = "weekly";
            persistent = true;
          };

          projects = {
            urls = [
              "https://veloren.net/rss.xml"
              "https://guix.gnu.org/feeds/blog.atom"
              "https://fedoramagazine.org/feed/"
              "https://nixos.org/blog/announcements-rss.xml"
            ];
            # Practically every 14 days.
            startAt = "Mon *-*-1/14";
          };
        };
      };

      services.gallery-dl = {
        enable = true;
        archivePath = "${mountName}/gallery-dl-service";

        extraArgs = [
          # Record all downloaded files in an archive file.
          "--download-archive" "${config.services.gallery-dl.archivePath}/photos"

          # Write metadata to separate JSON files.
          "--write-metadata"

          # The config file that contains the secrets for various services.
          # We're putting as a separate config file instead of configuring it
          # in the service properly since secrets decrypted by sops-nix cannot
          # be read in Nix.
          "--config" "${config.sops.secrets."multimedia-archive/secrets-config".path}"
        ];

        settings.extractor = {
          filename = "{date:%F}-{title}.{extension}";
        };

        jobs = {
          arts = {
            urls = [
              "https://www.deviantart.com/xezeno" # Xezeno
              #"https://www.pixiv.net/en/users/60562229" # Ravioli
              "https://www.artstation.com/kuvshinov_ilya" # Ilya Kuvshinov
              "https://www.artstation.com/meiipng" # Meiiart
              "https://www.artstation.com/bassem_wageeh" # Bassem wageeh
              "https://hyperjerk.newgrounds.com" # HyperJerk
            ];
            startAt = "weekly";
            persistent = true;
          };
        };
      };
    }
  );
}
