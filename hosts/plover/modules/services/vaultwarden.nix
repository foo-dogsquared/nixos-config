# An alternative implementation of Bitwarden written in Rust. The project
# being written in Rust is a insta-self-hosting material right there.
{ config, lib, pkgs, ... }:

let
  passwordManagerDomain = "pass.${config.networking.domain}";

  # This should be set from service module from nixpkgs.
  vaultwardenUser = config.users.users.vaultwarden.name;

  # However, this is set on our own.
  vaultwardenDbName = "vaultwarden";
in
{
  sops.secrets = lib.getSecrets ../../secrets/secrets.yaml {
    "vaultwarden/env".owner = vaultwardenUser;
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.secrets."vaultwarden/env".path;
    config = {
      DOMAIN = "https://${passwordManagerDomain}";

      # Configuring the server.
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      # Ehh... It's only a few (or even one) users anyways so nah. Since this
      # instance will not configure SMTP server, this pretty much means
      # invitation is only via email at this point.
      SHOW_PASSWORD_HINT = false;

      # Configuring some parts of account management which is almost
      # nonexistent because this is just intended for me (at least right now).
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;

      # Invitations...
      INVITATIONS_ALLOWED = true;
      INVITATION_ORG_NAME = "foodogsquared's Vaultwarden";

      # Notifications...
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_PORT = 3012;
      WEBSOCKET_ADDRESS = "0.0.0.0";

      # Enabling web vault with whatever nixpkgs comes in.
      WEB_VAULT_ENABLED = true;

      # Databasifications...
      DATABASE_URL = "postgresql://${vaultwardenUser}@/${vaultwardenDbName}";

      # Mailer service configuration (except the user and password).
      SMTP_HOST = "smtp.sendgrid.net";
      SMTP_PORT = 587;
      SMTP_FROM_NAME = "Vaultwarden";
      SMTP_FROM = "bot+vaultwarden@foodogsquared.one";
    };
  };

  services.postgresql = {
    ensureDatabases = [ vaultwardenDbName ];
    ensureUsers = [{
      name = vaultwardenUser;
      ensurePermissions = {
        "DATABASE ${vaultwardenDbName}" = "ALL PRIVILEGES";
        "SCHEMA ${vaultwardenDbName}" = "ALL PRIVILEGES";
      };
    }];
  };

  systemd.services.vaultwarden = {
    path = [ config.services.postgresql.package ];

    # Making it comply with PostgreSQL secure schema usage pattern.
    preStart = lib.mkAfter ''
      # Setting up the appropriate schema for PostgreSQL secure schema usage.
      psql -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name='${vaultwardenUser}';" \
        | grep -q 1 || psql -tAc "CREATE SCHEMA IF NOT EXISTS AUTHORIZATION ${vaultwardenUser};"
    '';

    # We do a little service hardening. Even though the Vaultwarden NixOS
    # module is already doing some of those things, we'll just add some of
    # them.
    serviceConfig = lib.mkAfter {
      LockPersonality = true;
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectHostname = true;
      ProtectControlGroups = true;
      ProtectProc = "invisible";

      # Filtering system calls.
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";

      # Restricting what capabilities it has access to which it
      # has none.
      CapabilityBoundingSet = [ "" ];
      AmbientCapability = [ "" ];

      # Restrict what address families this service can interact
      # with. Since it is a web service, we expect it will only
      # interact with web service stuff like IPs.
      RestrictAddressFamilies = [
        # It's required especially it can communicate with the local system.
        "AF_LOCAL"

        # The IPs.
        "AF_INET"
        "AF_INET6"
      ];

      # Restrict what namespaces it can create which is none.
      RestrictNamespaces = true;
    };
  };

  # Attaching it to our reverse proxy of choice.
  services.nginx.virtualHosts."${passwordManagerDomain}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations =
      let
        address = config.services.vaultwarden.config.ROCKET_ADDRESS;
        port = config.services.vaultwarden.config.ROCKET_PORT;
        websocketPort = config.services.vaultwarden.config.WEBSOCKET_PORT;
      in
      {
        "/" = {
          proxyPass = "http://${address}:${toString port}";
          proxyWebsockets = true;
        };

        "/notifications/hub" = {
          proxyPass = "http://${address}:${toString websocketPort}";
          proxyWebsockets = true;
        };

        "/notifications/hub/negotiate" = {
          proxyPass = "http://${address}:${toString port}";
          proxyWebsockets = true;
        };
      };
  };

  # Configuring fail2ban for this service which thankfully has a dedicated page
  # at https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup.
  services.fail2ban.jails = {
    vaultwarden-user.settings = {
      enabled = true;
      backend = "systemd";
      filter = "vaultwarden-user[journalmatch='_SYSTEMD_UNIT=vaultwarden.service + _COMM=vaultwarden']";
      maxretry = 5;
    };

    vaultwarden-admin.settings = {
      enabled = true;
      backend = "systemd";
      filter = "vaultwarden-admin[journalmatch='_SYSTEMD_UNIT=vaultwarden.service + _COMM=vaultwarden']";
      maxretry = 3;
    };
  };

  environment.etc = {
    "fail2ban/filter.d/vaultwarden-user.conf".text = ''
      [Includes]
      before = common.conf

      # For more information, Vaultwarden knowledge base has a dedicated page
      # for configuring fail2ban with the application (i.e.,
      # https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup).
      [Definition]
      failregex = ^.*Username or password is incorrect\. Try again\. IP: <HOST>\. Username:.*$
      ignoreregex =
    '';

    "fail2ban/filter.d/vaultwarden-admin.conf".text = ''
      [Includes]
      before = common.conf

      # For more information, Vaultwarden knowledge base has a dedicated page
      # for configuring fail2ban with the application (i.e.,
      # https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup).
      [Definition]
      failregex = ^.*Invalid admin token\. IP: <HOST>.*$
      ignoreregex =
    '';
  };

  # Add the data directory to be backed up.
  services.borgbackup.jobs.services-backup.paths = [ "/var/lib/bitwarden_rs" ];
}
