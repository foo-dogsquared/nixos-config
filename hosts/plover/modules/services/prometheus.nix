{ config, lib, pkgs, ... }:

let
  bindStatsPort = 8053;
  prometheusExports = config.services.prometheus.exporters;
in
{
  services.prometheus = {
    enable = true;

    exporters = {
      bind = {
        enable = true;
        bindURI = "http://127.0.0.1/${builtins.toString bindStatsPort}";
      };

      nginx.enable = true;
      nginxlog.enable = true;

      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
    };

    scrapeConfigs = [
      {
        job_name = config.networking.hostName;
        static_configs = [{
          targets = [ "127.0.0.1:${builtins.toString prometheusExports.node.port}" ];
        }];
      }
    ];
  };

  # Requiring this for Prometheus being able to monitor my services.
  services.nginx.statusPage = true;
  services.bind.extraConfig = ''
    statistics-channels {
      inet 127.0.0.1 port ${builtins.toString bindStatsPort} allow { 127.0.0.1; };
    };
  '';
}
