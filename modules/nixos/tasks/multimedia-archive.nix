{ config, options, lib, pkgs, ... }:

let cfg = config.tasks.multimedia-archive;
in {
  options.tasks.multimedia-archive.enable =
    lib.mkEnableOption "multimedia archiving setup";

  config = lib.mkIf cfg.enable {
    services.yt-dlp = {
      enable = true;
      archivePath = "/archives/yt-dlp-service";

      # This is applied on all jobs.
      # It is best to be minimal as much as possible for this.
      extraArgs = [
        # Make a global list of successfully downloaded videos as a cache for yt-dlp.
        "--download-archive videos"

        # No overwriting of videos and related files.
        "--no-force-overwrites"

        # Embed metadata in the file.
        "--embed-metadata"

        # Embed chapter markers, if possible.
        "--embed-chapters"

        # Write the subtitle file.
        "--write-subs"

        # Write the description in a separate file.
        "--write-description"

        # The global output for all of the jobs.
        "--output '%(artist,creator,uploader|Unknown)s/%(release_date>%F-%H-%M-%S|Unknown)s-%(title)s.%(ext)s'"

        # Prefer MKV whenever possible for video formats.
        "--merge-output-format mkv"

        # Prefer Vorbis when audio-only downloads are used.
        "--audio-format vorbis"
        "--audio-quality 2"
      ];

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
          startAt = "daily";
          extraArgs = [
            "--dateafter 'today-2weeks'" # Only get the videos uploaded after 2 weeks.
            "--playlist-end 50" # Only check the first N videos.
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
          startAt = "daily";
          extraArgs = [
            "--dateafter 'today-1month'" # Only get the uploaded videos from a month ago.
            "--playlist-end 50" # Only check the first N videos.
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
          startAt = "*-*-1/3"; # Every 3 days starting from the first day of the calendar.
          extraArgs = [
            "--dateafter 'today-1month'" # Only get the uploaded videos from a month ago.
            "--playlist-end 35" # Check the first N videos.
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
          startAt = "daily";
        };
      };
    };
  };
}
