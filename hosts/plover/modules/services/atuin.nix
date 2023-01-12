# A nice little sync server for my supercharged shell history done by Atuin.
# It's nice to have but not exactly what I need. It's just here because I want
# to give it a try.
{ config, lib, pkgs, ... }:

let
  atuinDomain = "atuin.${config.networking.domain}";
in {
  # Atuin sync server because why not.
  services.atuin = {
    enable = true;
    openFirewall = true;
    openRegistration = false;
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
  services.nginx.virtualHosts."${atuinDomain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.atuin.port}";
    };
  };
}
