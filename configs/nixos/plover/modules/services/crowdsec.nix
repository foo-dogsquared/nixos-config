{ config, lib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.crowdsec;
in {
  options.hosts.plover.services.crowdsec.enable =
    lib.mkEnableOption "Crowdsec service";

  config = lib.mkIf cfg.enable {
    services.crowdsec = {
      enable = true;
      settings = {
        common = {
          daemonize = false;
          log_media = "stdout";
        };
      };
    };
  };
}
