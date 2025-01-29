{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.music;
in {
  options.hosts.ni.setups.music.enable =
    lib.mkEnableOption "music streaming and organizing setup";

  config = lib.mkIf cfg.enable {
    state.ports = rec {
      gonic = {
        value = 4747;
        protocols = [ "tcp" ];
        openFirewall = true;
      };
      spotifyd = {
        value = 9009;
        openFirewall = true;
      };
      snapserver-tcp = {
        value = 9080;
        openFirewall = true;
      };
      snapserver-http = {
        value = 9011;
        openFirewall = true;
      };
      uxplay = {
        value = 10001;
        openFirewall = true;
      };
      uxplayClients = {
        value = foodogsquaredLib.nixos.makeRange' uxplay.value 10;
        openFirewall = true;
      };
    };

    # My portable music streaming server.
    services.gonic = {
      enable = true;
      settings = rec {
        listen-addr =
          "localhost:${builtins.toString config.state.ports.gonic.value}";
        cache-path = "${config.state.paths.cacheDir}/gonic";
        music-path = [ "/srv/Music" ];
        podcast-path = "${cache-path}/podcasts";
        playlists-path = "${cache-path}/playlists";

        jukebox-enabled = true;
        jukebox-mpv-extra-args = let
          args = [
            "--ao=pcm"
            "--ao-pcm-file=${config.state.paths.runtimeDir}/snapserver/jukebox"
          ];
        in lib.concatStringsSep " " args;

        scan-interval = 1;
        scan-at-start-enabled = true;
      };
    };

    services.spotifyd = {
      enable = false;
      settings.global = {
        autoplay = true;
        device_name = "My laptop";
        bitrate = 320;
        device_type = "computer";
        use_keyring = false;
        use_mpris = false;

        # We're relying on the local discovery.
        zeroconf_port = config.state.ports.spotifyd.value;
        no_audio_cache = true;
      };
    };

    services.snapserver = {
      enable = true;
      http = {
        enable = true;
        port = config.state.ports.snapserver-http.value;
        docRoot = "${pkgs.snapcast}/share/snapserver/snapweb";
      };
      tcp = {
        enable = true;
        port = config.state.ports.snapserver-tcp.value;
      };
      listenAddress = "127.0.0.1";

      streams = {
        gonic-jukebox = {
          type = "pipe";
          location = "/run/snapserver/jukebox";
          sampleFormat = "48000:16:2";
          codec = "pcm";
        };

        airplay = {
          type = "airplay";
          location = lib.getExe' pkgs.shairport-sync "shairport-sync";
          query = { devicename = "Snapcast"; };
        };

        spotify = {
          type = "librespot";
          location = lib.getExe' pkgs.librespot "librespot";
          query = {
            devicename = "Snapcast";
            bitrate = "320";
            volume = "50";
            normalize = "true";
            autoplay = "true";
          };
        };
      };
    };

    systemd.services.snapserver.serviceConfig = {
      SupplementaryGroups = [ "audio" ];
      RuntimeDirectoryMode = "0775";
    };

    systemd.services.gonic.serviceConfig = {
      SupplementaryGroups = [ "audio" ];
    };
  };
}
