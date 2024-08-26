{ config, lib, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.music;
in
{
  options.hosts.ni.setups.music.enable =
    lib.mkEnableOption "music streaming and organizing setup";

  config = lib.mkIf cfg.enable {
    state.ports = rec {
      gonic = {
        value = 4747;
        protocols = [ "tcp" ];
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
        listen-addr = "localhost:${builtins.toString config.state.ports.gonic.value}";
        cache-path = "/var/cache/gonic";
        music-path =
          [
            "/srv/Music"
          ];
        podcast-path = "${cache-path}/podcasts";
        playlists-path = "${cache-path}/playlists";

        jukebox-enabled = true;

        scan-interval = 1;
        scan-at-start-enabled = true;
      };
    };

    # My AirPlay mirroring server.
    services.uxplay = {
      enable = true;
      extraArgs = [
        "-p" (builtins.toString config.state.ports.uxplay.value)
        "-reset" "30"
      ];
    };
  };
}
