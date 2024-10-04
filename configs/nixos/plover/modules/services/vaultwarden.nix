# An alternative implementation of Bitwarden written in Rust. The project
# being written in Rust is a insta-self-hosting material right there.
{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.vaultwarden;

  passwordManagerDomain = "pass.${config.networking.domain}";

  # This should be set from service module from nixpkgs.
  vaultwardenUser = config.users.users.vaultwarden.name;
in {
  options.hosts.plover.services.vaultwarden.enable =
    lib.mkEnableOption "Vaultwarden instance";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.ports = {
        vaultwarden.value = 8222;
        vaultwarden-webproxy.value = 3012;
      };

      sops.secrets =
        foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
          "vaultwarden/env".owner = vaultwardenUser;
        };

      services.vaultwarden = {
        enable = true;
        environmentFile = config.sops.secrets."vaultwarden/env".path;
        config = {
          DOMAIN = "https://${passwordManagerDomain}";

          # Configuring the server.
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = config.state.ports.vaultwarden.value;

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
          WEBSOCKET_PORT = config.state.ports.vaultwarden-webproxy.value;
          WEBSOCKET_ADDRESS = "0.0.0.0";

          # Enabling web vault with whatever nixpkgs comes in.
          WEB_VAULT_ENABLED = true;
        };
      };

      systemd.services.vaultwarden.path = [ pkgs.system-sendmail ];
    }

    (lib.mkIf hostCfg.services.database.enable {
      services.vaultwarden = {
        dbBackend = "postgresql";
        config.DATABASE_URL = "postgresql://";
      };

      services.postgresql = {
        ensureDatabases = [ vaultwardenUser ];
        ensureUsers = lib.singleton {
          name = vaultwardenUser;
          ensureDBOwnership = true;
        };
      };

      systemd.services.vaultwarden.preStart = let
        psql = lib.getExe' config.services.postgresql.package "psql";
        schema = config.users.users.vaultwarden.name;
      in lib.mkBefore ''
        ${psql} -tAc "CREATE SCHEMA IF NOT EXISTS AUTHORIZATION ${schema};"
      '';
    })

    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      services.nginx.virtualHosts."${passwordManagerDomain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        kTLS = true;
        locations = let
          address = config.services.vaultwarden.config.ROCKET_ADDRESS;
          websocketPort = config.services.vaultwarden.config.WEBSOCKET_PORT;
        in {
          "/" = {
            proxyPass = "http://vaultwarden";
            proxyWebsockets = true;
          };

          "/notifications/hub" = {
            proxyPass = "http://${address}:${toString websocketPort}";
            proxyWebsockets = true;
          };

          "/notifications/hub/negotiate" = {
            proxyPass = "http://vaultwarden";
            proxyWebsockets = true;
          };
        };
        extraConfig = ''
          proxy_cache ${config.services.nginx.proxyCachePath.apps.keysZoneName};
        '';
      };

      services.nginx.upstreams."vaultwarden" = {
        extraConfig = ''
          zone services;
          keepalive 2;
        '';
        servers = let
          address = config.services.vaultwarden.config.ROCKET_ADDRESS;
          port = config.services.vaultwarden.config.ROCKET_PORT;
        in { "${address}:${builtins.toString port}" = { }; };
      };
    })

    (lib.mkIf hostCfg.services.backup.enable {
      # Add the data directory to be backed up.
      services.borgbackup.jobs.services-backup.paths =
        [ "/var/lib/bitwarden_rs" ];
    })

    (lib.mkIf hostCfg.services.fail2ban.enable {
      # Configuring fail2ban for this service which thankfully has a dedicated page
      # at https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup.
      services.fail2ban.jails = {
        vaultwarden-user.settings = {
          enabled = true;
          backend = "systemd";
          filter =
            "vaultwarden-user[journalmatch='_SYSTEMD_UNIT=vaultwarden.service + _COMM=vaultwarden']";
          maxretry = 5;
        };

        vaultwarden-admin.settings = {
          enabled = true;
          backend = "systemd";
          filter =
            "vaultwarden-admin[journalmatch='_SYSTEMD_UNIT=vaultwarden.service + _COMM=vaultwarden']";
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
          failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username: <F-USER>.*</F-USER>\.$
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
    })
  ]);
}
