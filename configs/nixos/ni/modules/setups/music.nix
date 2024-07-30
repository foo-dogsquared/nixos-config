{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.music;

  gonicPort = 4747;
  uxplayPort = gonicPort + 1;
in
{
  options.hosts.ni.setups.music.enable =
    lib.mkEnableOption "music streaming and organizing setup";

  config = lib.mkIf cfg.enable {
    # My portable music streaming server.
    services.gonic = {
      enable = true;
      settings = rec {
        listen-addr = "localhost:${builtins.toString gonicPort}";
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
      extraArgs = [ "-p" (builtins.toString uxplayPort) ];
    };

    networking.firewall.allowedTCPPorts = [ gonicPort uxplayPort ];
  };
}
