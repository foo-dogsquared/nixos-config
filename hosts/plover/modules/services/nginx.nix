# The reverse proxy of choice.
{ config, lib, pkgs, ... }:

{
  # The main server where it will tie all of the services in one neat little
  # place. Take note, the virtual hosts definition are all in their respective
  # modules.
  services.nginx = {
    enable = true;
    enableReload = true;

    package = pkgs.nginxMainline;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  # Some fail2ban policies to apply for nginx.
  services.fail2ban.jails = {
    nginx-http-auth = "enabled = true";
    nginx-botsearch = "enabled = true";
  };
}
