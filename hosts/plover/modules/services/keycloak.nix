# Centralizing them signing in to web applications (plus LDAP).
{ config, lib, pkgs, ... }:

let
  inherit (import ../hardware/networks.nix) preferredInternalTLD interfaces;

  authDomain = "auth.${config.networking.domain}";
  authInternalDomain = "auth.${config.networking.domain}.${preferredInternalTLD}";

  # This is also set on our own.
  keycloakUser = config.services.keycloak.database.username;
  keycloakDbName = if config.services.keycloak.database.createLocally then keycloakUser else config.services.keycloak.database.username;

  certs = config.security.acme.certs;
  host = interfaces.internal.IPv4.address;
in
{
  # Hey, the hub for your application sign-in.
  services.keycloak = {
    enable = true;

    # Pls change at first login. Or just change it through `kcadm.sh`.
    initialAdminPassword = "wow what is this thing";

    database = {
      type = "postgresql";
      createLocally = true;
      passwordFile = config.sops.secrets."plover/keycloak/db/password".path;
    };

    settings = {
      inherit host;

      db-schema = keycloakDbName;

      http-enabled = true;
      http-port = 8759;
      https-port = 8760;

      hostname = authDomain;
      hostname-strict-backchannel = true;
      proxy = "passthrough";
    };

    sslCertificate = "${certs."${authDomain}".directory}/fullchain.pem";
    sslCertificateKey = "${certs."${authDomain}".directory}/key.pem";
  };

  # Modifying it a little bit for per-user schema.
  systemd.services.keycloak = {
    path = [ config.services.postgresql.package ];
    preStart = ''
      psql -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name='${keycloakDbName}';" \
        grep -q 1 || psql -tAc "CREATE SCHEMA IF NOT EXISTS keycloak;"
    '';
  };

  # Configuring the database of choice to play nicely with the service.
  services.postgresql = {
    ensureDatabases = [ keycloakDbName ];
    ensureUsers = [
      {
        name = keycloakUser;
        ensurePermissions = {
          "DATABASE ${keycloakDbName}" = "ALL PRIVILEGES";
          "SCHEMA ${keycloakDbName}" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # Attach an domain name to the DNS server.
  services.dnsmasq.settings.address = [ "/${authInternalDomain}/${host}" ];

  # Attaching it to the reverse proxy of choice.
  services.nginx.virtualHosts = {
    "${authDomain}" = {
      forceSSL = true;
      enableACME = true;

      # This is based from the reverse proxy guide from the official
      # documentation at https://www.keycloak.org/server/reverseproxy.
      locations = let
        keycloakPath = path: "http://${host}:${toString config.services.keycloak.settings.http-port}";
      in
      lib.listToAttrs
        (lib.lists.map
          (appPath: lib.nameValuePair appPath { proxyPass = keycloakPath appPath; })
          [ "/js/" "/realms/" "/resources/" "/robots.txt" ]);
    };

    "${authInternalDomain}" = {
      locations."/" = {
        proxyPass = "http://${host}:${toString config.services.keycloak.settings.http-port}";
      };
    };
  };

  # Configuring fail2ban for this services which is only present as a neat
  # little hint from its server administration guide.
  services.fail2ban.jails = {
    keycloak = ''
      enabled = true
      backend = systemd
      filter = keycloak[journalmatch='_SYSTEMD_UNIT=keycloak.service']
      maxretry = 3
    '';
  };

  environment.etc = {
    "fail2ban/filter.d/keycloak.conf".text = ''
      [Includes]
      before = common.conf

      # This is based from the server administration guide at
      # https://www.keycloak.org/docs/$VERSION/server_admin/index.html.
      [Definition]
      failregex = ^.*type=LOGIN_ERROR.*ipAddress=<HOST>.*$
      ignoreregex =
    '';
  };
}
