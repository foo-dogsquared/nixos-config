{ config, lib, pkgs, ... }:

let
  cfg = config.shared-setups.server.crowdsec;
in
{
  options.shared-setups.server.crowdsec.enable =
    lib.mkEnableOption "typical Crowdsec setup for public-facing servers";

  config = lib.mkIf cfg.enable {
    services.crowdsec = {
      enable = true;
      settings = {
        common = {
          daemonize = false;
          log_media = "stdout";
        };
      };

      plugins = {
        http = {
          settings = {
            type = "http";
            log_level = "info";
          };
        };
      };
    };
  };
}
