# A nice little sync server for my supercharged shell history done by Atuin.
# It's nice to have but not exactly what I need. It's just here because I want
# to give it a try.
{ config, lib, pkgs, ... }:

let
  inherit (import ../hardware/networks.nix) preferredInternalTLD interfaces;

  atuinInternalDomain = "atuin.${config.networking.domain}.${preferredInternalTLD}";
  host = interfaces.internal.IPv4.address;
in
{
  # Atuin sync server because why not.
  services.atuin = {
    enable = true;
    openRegistration = false;

    inherit host;
    port = 8965;
  };

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

  # Putting it altogether in the reverse proxy of choice.
  services.nginx.virtualHosts."${atuinInternalDomain}" = {
    locations."/" = {
      proxyPass = "http://${host}:${toString config.services.atuin.port}";
    };
  };
}
