{ config, options, lib, pkgs, ... }:

let cfg = config.tasks.multimedia-archive;
in {
  options.tasks.multimedia-archive.enable =
    lib.mkEnableOption "multimedia archiving setup";

  config = lib.mkIf cfg.enable (let
    yt-dlp-args = [
      # Make a global list of successfully downloaded videos as a cache for yt-dlp.
      "--download-archive ${config.services.yt-dlp.archivePath}/videos"

      # No overwriting of videos and related files.
      "--no-force-overwrites"

      # Embed metadata in the file.
      "--write-info-json"

      # Embed chapter markers, if possible.
      "--embed-chapters"

      # Write the subtitle file.
      "--write-subs"

      # Write the description in a separate file.
      "--write-description"

      # The global output for all of the jobs.
      "--output '%(uploader,artist,creator|Unknown)s/%(release_date>%F,upload_date>%F|Unknown)s-%(title)s.%(ext)s'"

      # Select only the most optimal format for my usecases.
      "--format '(webm,mkv,mp4)[height<=?1280]'"

      # Prefer MKV whenever possible for video formats.
      "--merge-output-format mkv"

      # Don't download any videos that are originally live streams.
      "--match-filters '!was_live'"

      # Prefer Vorbis when audio-only downloads are used.
      "--audio-format vorbis"
      "--audio-quality 2"
    ];
    yt-dlp-archive-variant = pkgs.writeScriptBin "yt-dlp-archive-variant" ''
      ${pkgs.yt-dlp}/bin/yt-dlp ${lib.escapeShellArgs yt-dlp-args}
    '';
  in {
    environment.systemPackages = [ yt-dlp-archive-variant ];

    services.yt-dlp = {
      enable = true;
      archivePath = "/archives/yt-dlp-service";

      # This is applied on all jobs. It is best to be minimal as much as
      # possible for this.
      extraArgs = yt-dlp-args;

      jobs = {
        arts = {
          urls = [
            "https://www.youtube.com/channel/UCjdHbo8_vh3rxQ-875XGkvw" # 3DSage
            "https://www.youtube.com/channel/UCHv_hNLkxqlcY20MwVyayfw" # Ali Bahabadi
            "https://www.youtube.com/c/DavidRevoy" # David Revoy
            "https://www.youtube.com/channel/UCGMyyn2FdEFcDfP1wQRh5lQ" # Erindale
            "https://www.youtube.com/c/Jazza" # Jazza
            "https://www.youtube.com/channel/UCcBnT6LsxANZjUWqpjR8Jpw" # Marcello Barenghi
            "https://www.youtube.com/c/ronillust" # ronillust
          ];
          startAt = "Friday";
          extraArgs = [
            "--playlist-end 20" # Only check the first N videos.
          ];
        };

        compsci = {
          urls = [
            "https://www.youtube.com/channel/UC_mYaQAE6-71rjSN6CeCA-g" # NeetCode
            "https://www.youtube.com/c/ThePrimeagen" # ThePrimeagen
            "https://www.youtube.com/c/EasyTheory" # EasyTheory
            "https://www.youtube.com/c/K%C3%A1rolyZsolnai" # Two Minute Papers
            "https://www.youtube.com/c/TheCodingTrain" # TheCodingTrain
          ];
          startAt = "Thursday";
          extraArgs = [
            "--playlist-end 20" # Only check the first N videos.
          ];
        };

        cooking = {
          urls = [
            "https://www.youtube.com/channel/UCJHA_jMfCvEnv-3kRjTCQXw" # Babish Culinary Universe
            "https://www.youtube.com/channel/UCb5QRUn5w8_g0j8QVaWzcjQ" # BORE.D
            "https://www.youtube.com/channel/UCzqbfYjQmf9nLQPMxVgPhiA" # emmymade
            "https://www.youtube.com/channel/UCgmOd6sRQRK7QoSazOfaIjQ" # Emma's Goodies
            "https://www.youtube.com/channel/UCcp9uRaBwInxl_SZqGRksDA" # Hidamari Cooking
            "https://www.youtube.com/channel/UCvQrjgLj841wiQAKDgtKFOw" # Ninong Ry
            "https://www.youtube.com/channel/UCekQr9znsk2vWxBo3YiLq2w" # You Suck at Cooking
            "https://www.youtube.com/channel/UCUAKaXyq2hVBCph1LOUtuqg" # 집밥요리 Home Cooking
          ];
          startAt = "Sunday";
          extraArgs = [
            "--playlist-end 15" # Check the first N videos.
          ];
        };
      };
    };

    services.gallery-dl = {
      enable = true;
      archivePath = "/archives/gallery-dl-service";
      extraArgs = [
        # Record all downloaded files in an archive file.
        "--download-archive ${config.services.gallery-dl.archivePath}/photos"

        # Write metdata to info.json file.
        "--write-info-json"
      ];

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
        };
      };
    };
  });
}
