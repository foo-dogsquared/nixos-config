{ config, lib, pkgs, foodogsquaredLib, ... }@attrs:

let
  inherit (foodogsquaredLib.trivial) unitsToInt;
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.music;

  isFilesystemSet = setupName:
    attrs.nixosConfig.suites.filesystem.setups.${setupName}.enable or false;

  musicDir = config.xdg.userDirs.music;
  playlistsDir = "${musicDir}/playlists";
in {
  options.users.foo-dogsquared.setups.music = {
    enable = lib.mkEnableOption "foo-dogsquared's music setup";
    mpd.enable = lib.mkEnableOption "foo-dogsquared's MPD server setup";
    spotify.enable = lib.mkEnableOption "music streaming setup with Spotify";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        songrec # SHAZAM!
        picard # Graphical beets.
      ];

      wrapper-manager.packages.music-setup = {
        wrappers.yt-dlp-music = {
          arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
          prependArgs = [ "--config-location" ../../../config/yt-dlp/audio.conf ];
        };
      };

      # Enable the desktop audio profile for extra auditorial goodies.
      suites.desktop.audio = {
        enable = lib.mkDefault true;
        pipewire.enable = lib.mkDefault true;
      };

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

      # Set every music-related services from the encompassing NixOS
      # configuration.
      users.foo-dogsquared.programs.custom-homepage.sections = lib.mkMerge [
        (lib.mkIf (attrs.nixosConfig.services.gonic.enable or false) (let
          subsonicLink = {
            url = "http://localhost:${
                builtins.toString attrs.nixosConfig.state.ports.gonic.value
              }";
            text = "Jukebox server";
          };
        in {
          services.links = lib.singleton subsonicLink;
          music.links = lib.mkBefore
            [ (subsonicLink // { text = "Subsonic music server"; }) ];
        }))
      ];

      wrapper-manager.packages.web-apps.wrappers = let
        inherit (foodogsquaredLib.wrapper-manager) commonChromiumFlags wrapChromiumWebApp;
        chromiumPackage = config.state.packages.chromiumWrapper;

        mkFlags = name: commonChromiumFlags ++ [
          "--user-data-dir=${config.xdg.configHome}/${chromiumPackage.pname}-${name}"
        ];
      in {
        yt-music = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "yt-music";
          url = "https://music.youtube.com";
          imageHash = "";
          appendArgs = mkFlags name ++ [
            # This is required for DRM.
            "--enable-nacl"
          ];
          xdg.desktopEntry.settings = {
            desktopName = "YouTube Music";
            genericName = "Music Streaming Service";
            comment = "Music streaming from YouTube";
            categories = [ "Audio" "Music" "Player" "AudioVideo" ];
            keywords = [
              "YouTube"
              "Music Player"
              "Online Music Streaming"
            ];
          };
        };
      };
    }

    (lib.mkIf cfg.spotify.enable {
      xdg.autostart.entries =
        lib.singleton (foodogsquaredLib.xdg.getXdgDesktop pkgs.spotify "spotify");

      sops.secrets."mopidy/spotify" = foodogsquaredLib.sops-nix.getAsOneSecret ./spotify.secrets.bin;

      state.ports.spotifyd.value =
        attrs.nixosConfig.services.spotifyd.value or 9009;

      services.mopidy = {
        extensionPackages = [ pkgs.mopidy-spotify ];
        extraConfigFiles = lib.singleton config.sops.secrets."mopidy/spotify".path;
      };

      wrapper-manager.packages.web-apps.wrappers = let
        inherit (foodogsquaredLib.wrapper-manager) wrapChromiumWebApp commonChromiumFlags;

        chromiumPackage = config.state.packages.chromiumWrapper;

        mkFlags = name: commonChromiumFlags ++ [
          "--user-data-dir=${config.xdg.configHome}/${chromiumPackage.pname}-${name}"
        ];
      in {
        spotify = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "spotify";
          url = "https://open.spotify.com/";
          imageHash = "sha512-caFOXceJa0q+/LVOrKbR5wviSJFwrahehdZ2Dmv+BTmAkDhfWjwl6tpf690vI17S998Ohe+J9trLMjYX+BihEQ==";
          appendArgs = mkFlags name ++ [
            # This is required for DRM.
            "--enable-nacl"
          ];
          xdg.desktopEntry.settings = {
            desktopName = "Spotify";
            genericName = "Music Streaming Client";
            comment = "Play with a music library from millions of artists";
            mimeTypes = [ "x-scheme-handler/spotify" ];
            categories = [ "Audio" "Music" "Player" "AudioVideo" ];
            keywords = [
              "Music Player"
              "Online Music Streaming"
            ];
          };
        };
      };
    })

    (lib.mkIf (cfg.spotify.enable
      && !(attrs.nixosConfig.services.spotifyd.enable or false)) {
        services.spotifyd = {
          enable = true;
          settings.global = {
            use_mpris = true;
            device_name = "foodogsquared's computer";
            bitrate = 320;
            device_type = "computer";
            zeroconf_port = config.state.ports.spotifyd.value;

            cache_path = "${config.xdg.cacheHome}/spotifyd";
            max_cache_size = unitsToInt {
              size = 4;
              prefix = "G";
            };
          };
        };
      })

    (lib.mkIf cfg.mpd.enable {
      state.ports.mopidy.value = 6680;

      sops.secrets."mopidy/listenbrainz" = foodogsquaredLib.sops-nix.getAsOneSecret ./mopidy-listenbrainz.secrets.bin;

      services.mopidy = {
        enable = true;

        extraConfigFiles = [
          config.sops.secrets."mopidy/listenbrainz".path
        ];

        extensionPackages = with pkgs; [
          mopidy-funkwhale
          mopidy-internetarchive
          mopidy-listenbrainz
          mopidy-iris
          mopidy-local
          mopidy-mpd
          mopidy-mpris
          mopidy-youtube
        ];

        settings = let
          # Typically used for conditional portions of the configuration. Any
          # part that doesn't have the check typically means it's always used
          # or assumed to be a part of the bundled extensions.
          isInPackageList = pkg: lib.elem pkg config.services.mopidy.extensionPackages;
        in {
          http = {
            hostname = "127.0.0.1";
            port = config.state.ports.mopidy.value;
            default_app = "iris";
          };

          file = {
            enabled = true;
            media_dirs = [ "$XDG_MUSIC_DIR|Music" "~/library/music|Library" ]
              ++ lib.optional (isFilesystemSet "external-hdd")
              "${attrs.nixosConfig.state.paths.external-hdd}/Music|External storage"
              ++ lib.optional (isFilesystemSet "archive")
              "${attrs.nixosConfig.state.paths.archive}/Music|Archive";
          };

          internetarchive = lib.mkIf (isInPackageList pkgs.mopidy-internetarchive) {
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

          listenbrainz = lib.mkIf (isInPackageList pkgs.mopidy-listenbrainz) {
            enabled = true;
            import_playlists = true;
            search_schemes =
              lib.optionals (isInPackageList pkgs.mopidy-local) [ "local:" ]
              ++ lib.optionals (isInPackageList pkgs.mopidy-spotify) [ "spotify:" ]
              ++ lib.optionals (isInPackageList pkgs.mopidy-funkwhale) [ "funkwhale:" ]
              ++ lib.optionals (isInPackageList pkgs.mopidy-youtube) [ "youtube:" ];
          };

          m3u = lib.mkIf (isInPackageList pkgs.mopidy-local) {
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

      # Set this to the custom homepage.
      users.foo-dogsquared.programs.custom-homepage.sections = let
        mopidyLink = {
          url = "http://localhost:${
              builtins.toString config.state.ports.mopidy.value
            }";
          text = "Music streaming server";
        };
      in {
        services.links = lib.singleton mopidyLink;
        music.links =
          lib.mkBefore [ (mopidyLink // { text = "Mopidy server"; }) ];
      };
    })
  ]);
}
