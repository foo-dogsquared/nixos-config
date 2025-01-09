{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.dns-server;
in
{
  options.hosts.ni.services.dns-server.enable =
    lib.mkEnableOption "preferred DNS server";

  config = lib.mkIf cfg.enable {
    services.nsd = {
      enable = true;
      ipv4 = true;
      ipv6 = true;

      zones."foodogsquared.internal".data = ''
        $ORIGIN foodogsquared.internal.
        $TTL 3600

        @ IN SOA ns1.foodogsquared.internal. admin.foodogsquared.one. (
          2025010101  ;Serial
          3600        ;Refresh
          3600        ;Retry
          3600        ;Expire
          3600        ;Negative response caching TTL
        )
          3600  IN  NS  ns1.foodogsquared.internal.

        ni   3600  IN  A  127.0.0.1
        ns1  3600  IN  A  127.0.0.1
        rss  3600  IN  A  127.0.0.1
      '';
    };

    services.resolved.domains = [ "~foodogsquared.internal" ];
    networking.nameservers = [ "127.0.0.1" ];
  };
}
