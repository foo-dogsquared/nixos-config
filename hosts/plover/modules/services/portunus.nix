# The LDAP server of choice. Though, it really uses OpenLDAP as the backend so
# it's really more like a nice frontend for it so you don't have to experience
# the pain of managing an OpenLDAP server.
{ config, lib, pkgs, ... }:

let
  ldapDomain = "ldap.${config.networking.fqdn}";
in
{
  services.portunus = {
    enable = true;

    port = 8168;
    domain = ldapDomain;

    ldap = {
      searchUserName = "admin";
      suffix = "dc=foodogsquared,dc=one";
      tls = true;
    };

    seedPath =
      let
        seedData = {
          groups = [
            {
              name = "admin-team";
              long_name = "Portunus Administrators";
              members = [ "foodogsquared" ];
              permissions = {
                portunus.is_admin = true;
                ldap.can_read = true;
              };
            }
          ];
          users = [
            {
              login_name = "foodogsquared";
              given_name = "Gabriel";
              family_name = "Arazas";
              email = "foodogsquared@${config.networking.domain}";
              ssh_public_keys =
                let
                  readFiles = list: lib.lists.map (path: lib.readFile path) list;
                in
                readFiles [
                  ../../../../users/home-manager/foo-dogsquared/files/ssh-key.pub
                  ../../../../users/home-manager/foo-dogsquared/files/ssh-key-2.pub
                ];
              password.from_command = [ "${pkgs.coreutils}/bin/cat" config.sops.secrets."plover/ldap/users/foodogsquared/password".path ];
            }
          ];
        };
        settingsFormat = pkgs.formats.json { };
      in
      settingsFormat.generate "portunus-seed" seedData;
  };

  # Getting this to be accessible in the reverse proxy of choice.
  services.nginx.virtualHosts."${ldapDomain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.portunus.port}";
    };
  };
}
