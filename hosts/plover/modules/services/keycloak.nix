# Centralizing them signing in to web applications (plus LDAP).
{ config, lib, pkgs, ... }:

let
  authDomain = "auth.${config.networking.domain}";

  # This is also set on our own.
  keycloakUser = config.services.keycloak.database.username;
  keycloakDbName = if config.services.keycloak.database.createLocally then keycloakUser else config.services.keycloak.database.username;

  certs = config.security.acme.certs;
in {
  # Hey, the hub for your application sign-in.
  services.keycloak = {
    enable = true;

    # Pls change at first login.
    initialAdminPassword = "wow what is this thing";

    database = {
      type = "postgresql";
      createLocally = true;
      passwordFile = config.sops.secrets."plover/keycloak/db/password".path;
    };

    settings = {
      host = "127.0.0.1";

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

  # Attaching it to the reverse proxy of choice.
  services.nginx.virtualHosts."${authDomain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}";
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
