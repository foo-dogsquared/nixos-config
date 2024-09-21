# The reverse proxy of choice. Logs should be rotated weekly.
{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.reverse-proxy;
in
{
  options.hosts.plover.services.reverse-proxy.enable =
    lib.mkEnableOption "preferred public-facing reverse proxy";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # The main server where it will tie all of the services in one neat little
      # place. Take note, the virtual hosts definition are all in their respective
      # modules.
      services.nginx = {
        enable = true;
        enableReload = true;

        package = pkgs.nginxMainline;

        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        # Some more server-sided compressions.
        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedZstdSettings = true;

        proxyCachePath.apps = {
          enable = true;
          keysZoneName = "apps";
        };

        appendConfig = ''
          worker_processes auto;
        '';

        # We're avoiding any service to be the default server especially that it
        # could be used for enter a service with unencrypted HTTP. So we're setting
        # up one with an unresponsive server response.
        appendHttpConfig = ''
          # https://docs.nginx.com/nginx/admin-guide/content-cache/content-caching/
          proxy_cache_min_uses 5;
          proxy_cache_valid 200 302 10m;
          proxy_cache_valid 404 1m;
          proxy_no_cache $http_pragma $http_authorization;

          server {
            listen 80 default_server;
            listen [::]:80 default_server;
            return 444;
          }
        '';

        # This is defined for other services.
        upstreams."nginx" = {
          extraConfig = ''
            zone services 64k;
          '';
          servers = {
            "localhost:80" = { };
          };
        };
      };

      networking.firewall.allowedTCPPorts = [
        80 # HTTP servers.
        443 # HTTPS servers.
      ];

      # Generate a DH parameters for nginx-specific security configurations.
      security.dhparams.params.nginx.bits = 4096;
    }

    (lib.mkIf hostCfg.services.fail2ban.enable {
      # Some fail2ban policies to apply for nginx.
      services.fail2ban.jails = {
        nginx-http-auth.settings = { enabled = true; };
        nginx-botsearch.settings = { enabled = true; };
        nginx-bad-request.settings = { enabled = true; };
      };
    })

    (lib.mkIf hostCfg.services.monitoring.enable {
      # Requiring this for Prometheus being able to monitor my services.
      services.nginx.statusPage = true;

      services.prometheus.exporters = {
        nginx.enable = true;
        nginxlog.enable = true;
      };
    })
  ]);
}
