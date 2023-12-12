{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.music;

  ytdlpAudio = pkgs.writeScriptBin "yt-dlp-audio" ''
    ${pkgs.yt-dlp}/bin/yt-dlp --config-location "${../config/yt-dlp-audio.conf}" $@
  '';

  musicDir = config.xdg.userDirs.music;
  playlistsDir = "${musicDir}/playlists";
in
{
  options.users.foo-dogsquared.music = {
    enable = lib.mkEnableOption "foo-dogsquared's music setup";
    mpd.enable = lib.mkEnableOption "foo-dogsquared's MPD server setup";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        songrec # SHAZAM!
        ytdlpAudio # My custom script for downloading music with yt-dlp.
        picard # Graphical beets.
      ];

      # Enable the desktop audio profile for extra auditorial goodies.
      profiles.desktop.audio.enable = true;

      # My music player setup, completely configured with Nix!
      programs.beets = {
        enable = true;
        settings = {
          library = "${musicDir}/library.db";
          plugins = [
            "acousticbrainz"
            "chroma"
            "edit"
            "export"
            "fetchart"
            "fromfilename"
            "fuzzy"
            "mbsync"
            "playlist"
            "scrub"
            "smartplaylist"
          ];
          ignore_hidden = true;
          directory = musicDir;
          ui.color = true;

          import = {
            move = true;
            link = false;
            resume = true;
            incremental = true;
            group_albums = true;
            log = "beets.log";
          };

          match.ignore_video_tracks = true;

          # Plugins configuration.
          fuzzy.prefix = "-";
          scrub.auto = true;
          smartplaylist = {
            relative_to = musicDir;
            playlist_dir = playlistsDir;
            playlists = [
              {
                name = "all.m3u8";
                query = "";
              }
              {
                name = "released-in-$year.m3u8";
                query = "year:2000..2023";
              }
            ];
          };
        };
      };

      # Add more cleaners.
      services.bleachbit.cleaners = [
        "audacious.log"
        "audacious.cache"
        "audacious.mru"
        "vlc.memory_dump"
        "vlc.mru"
      ];
    }

    (lib.mkIf cfg.mpd.enable {
      services.mopidy = {
        enable = true;
        extensionPackages = with pkgs; [
          mopidy-funkwhale
          mopidy-internetarchive
          mopidy-iris
          mopidy-local
          mopidy-mpd
          mopidy-mpris
          mopidy-youtube
        ];

        settings = {
          http = {
            hostname = "127.0.0.1";
            port = 6680;
            default_app = "iris";
          };

          file = {
            enabled = true;
            media_dirs = [
              "$XDG_MUSIC_DIR|Music"
              "~/library/music|Library"
            ];
          };

          internetarchive = {
            enabled = true;
            browse_limit = 150;
            search_limit = 150;
            collections = [
              "fav-foo-dogsquared"
              "audio"
              "etree"
              "audio_music"
              "audio_foreign"
            ];
          };

          m3u = {
            enabled = true;
            base_dir = musicDir;
            playlists_dir = playlistsDir;
            default_encoding = "utf-8";
            default_extension = ".m3u8";
          };
        };
      };

      # Configure a MPD client.
      programs.ncmpcpp = {
        enable = true;
        mpdMusicDir = musicDir;
      };
    })
  ]);
}
