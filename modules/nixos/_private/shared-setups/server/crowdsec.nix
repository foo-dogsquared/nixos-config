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

      notificationPlugins = {
        http = {
          settings = {
            type = "http";
            log_level = "info";
          };
        };
      };

      dataSources = {
        ssh = lib.mkIf config.services.sshd.enable {
          source = "journalctl";
          journalctl_filter = [
            "_SYSTEMD_UNIT=ssh.service"
          ];
          labels.type = "syslog";
        };
      };
    };
  };
}
