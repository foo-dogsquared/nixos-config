# The reverse proxy of choice. Logs should be rotated weekly.
{ config, lib, pkgs, ... }:

{
  # The main server where it will tie all of the services in one neat little
  # place. Take note, the virtual hosts definition are all in their respective
  # modules.
  services.nginx = {
    enable = true;
    enableReload = true;

    package = pkgs.nginxMainline;

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # We're avoiding any service to be the default server especially that it
    # could be used for enter a service with unencrypted HTTP. So we're setting
    # up one with an unresponsive server response.
    appendHttpConfig = ''
      server {
        listen 80 default_server;
        listen [::]:80 default_server;
        return 444;
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80 # HTTP servers.
    443 # HTTPS servers.
  ];

  # Some fail2ban policies to apply for nginx.
  services.fail2ban.jails = {
    nginx-http-auth.settings = { enabled = true; };
    nginx-botsearch.settings = { enabled = true; };
    nginx-bad-request.settings = { enabled = true; };
  };
}
