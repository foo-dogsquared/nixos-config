{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.music;
in
{
  options.hosts.ni.setups.music.enable =
    lib.mkEnableOption "music streaming and organizing setup";

  config = lib.mkIf cfg.enable {
    # My portable music streaming server.
    services.gonic = {
      enable = true;
      settings = {
        listen-addr = "localhost:4747";
        cache-path = "/var/cache/gonic";
        music-path =
          [
            "/srv/Music"
          ]
          ++ lib.optionals config.suites.filesystem.setups.external-hdd.enable [
            "/mnt/external-storage/Music"
          ];
        podcast-path = "/var/cache/gonic/podcasts";

        jukebox-enabled = true;

        scan-interval = 1;
        scan-at-start-enabled = true;
      };
    };
  };
}
