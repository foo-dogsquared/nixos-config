{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.monitoring;
in
{
  options.hosts.ni.services.monitoring.enable =
    lib.mkEnableOption "enable local desktop monitoring service";

  config = lib.mkIf cfg.enable {
    state.ports.grafana.value = 24532;

    services.grafana.enable = true;

    services.grafana.declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
    ];

    services.grafana.settings = {
      database.type = "sqlite3";
      server = {
        http_address = "localhost";
        http_port = config.state.ports.grafana.value;
      };

      # It's a local instance for a local use so there's not much to
      # worry about.
      security = {
        admin_password = "admin";
        admin_user = "admin";
      };
    };
  };
}
