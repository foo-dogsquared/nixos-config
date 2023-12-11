# A nice little sync server for my supercharged shell history done by Atuin.
# It's nice to have but not exactly what I need. It's just here because I want
# to give it a try.
{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.atuin;

  inherit (import ../hardware/networks.nix) interfaces;

  atuinInternalDomain = "atuin.${config.networking.fqdn}";
  host = interfaces.lan.IPv4.address;
in
{
  options.hosts.plover.services.atuin.enable = lib.mkEnableOption "Atuin sync server setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Atuin sync server because why not.
      services.atuin = {
        enable = true;
        openRegistration = true;

        inherit host;
        port = 8965;
      };
    }

    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      # Putting it altogether in the reverse proxy of choice.
      services.nginx.virtualHosts."${atuinInternalDomain}" = {
        locations."/" = {
          proxyPass = "http://${host}:${toString config.services.atuin.port}";
        };
      };
    })

    (lib.mkIf hostCfg.services.database.enable {
      # Putting a neat little script to create the appropriate schema since we're
      # using secure schema usage pattern as encouraged from PostgreSQL
      # documentation.
      systemd.services.atuin = {
        path = [ config.services.postgresql.package ];
        preStart = ''
          psql -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name='atuin';" \
            grep -q 1 || psql -tAc "CREATE SCHEMA IF NOT EXISTS atuin;"
        '';
      };
    })
  ]);
}
