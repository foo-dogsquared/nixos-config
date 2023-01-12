{ config, options, lib, pkgs, modulesPath, ... }:

let
  inherit (builtins) toString;

  domain = config.networking.domain;
  subdomain = prefix: "${prefix}.${domain}";

  passwordManagerDomain = subdomain "pass";
  codeForgeDomain = subdomain "code";
  authDomain = subdomain "auth";
  ldapDomain = subdomain "ldap";
  atuinDomain = subdomain "atuin";

  certs = config.security.acme.certs;

  # This should be set from service module from nixpkgs.
  vaultwardenUser = config.users.users.vaultwarden.name;

  # However, this is set on our own.
  vaultwardenDbName = "vaultwarden";

  # This is also set on our own.
  keycloakUser = config.services.keycloak.database.username;
  keycloakDbName = if config.services.keycloak.database.createLocally then keycloakUser else config.services.keycloak.database.username;

  # The head of the Borgbase hostname.
  hetzner-boxes-user = "u332477";
  hetzner-boxes-server = "${hetzner-boxes-user}.your-storagebox.de";
in
{
  imports = [
    ./hardware-configuration.nix

    # The users for this host.
    (lib.getUser "nixos" "admin")
    (lib.getUser "nixos" "plover")

    # Hardened profile from nixpkgs.
    "${modulesPath}/profiles/hardened.nix"
  ];

  boot.loader.grub.enable = true;

  networking = {
    nftables.enable = true;
    domain = "foodogsquared.one";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # Secure Shells.

        80 # HTTP servers.
        433 # HTTPS servers.

        389 # LDAP servers.
        636 # LDAPS servers.
      ];
    };
  };

  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ./secrets/secrets.yaml;
      };
      getSecrets = secrets:
        lib.mapAttrs'
          (secret: config:
            lib.nameValuePair
              "plover/${secret}"
              ((getKey secret) // config))
          secrets;

      giteaUserGroup = config.users.users."${config.services.gitea.user}".group;

      # It is hardcoded but as long as the module is stable that way.
      vaultwardenUserGroup = config.users.groups.vaultwarden.name;
      postgresUserGroup = config.users.groups.postgres.name;
    in
    getSecrets {
      "ssh-key" = { };
      "lego/env" = { };
      "gitea/db/password".owner = giteaUserGroup;
      "gitea/smtp/password".owner = giteaUserGroup;
      "vaultwarden/env".owner = vaultwardenUserGroup;
      "borg/repos/host/patterns/keys" = { };
      "borg/repos/host/password" = { };
      "borg/repos/services/password" = { };
      "borg/ssh-key" = { };
      "keycloak/db/password".owner = postgresUserGroup;
      "ldap/users/foodogsquared/password".owner = config.services.portunus.user;
    };

  # All of the keys required to deploy the secrets. Don't know how to make the
  # GCP KMS key work though without manually going into the instance and
  # configure it there.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  profiles.server = {
    enable = true;
    headless.enable = true;
    hardened-config.enable = true;
    cleanup.enable = true;
  };

  services.fail2ban.jails = {
    nginx-http-auth = "enabled = true";
    nginx-botsearch = "enabled = true";

    # Max retries are pretty much based from whether or not the jail is
    # attached to a more important service.
    vaultwarden-user = ''
      enabled = true
      backend = systemd
      filter = vaultwarden-user[journalmatch='_SYSTEMD_UNIT=vaultwarden.service']
      maxretry = 5
    '';

    vaultwarden-admin = ''
      enabled = true
      backend = systemd
      filter = vaultwarden-admin[journalmatch='_SYSTEMD_UNIT=vaultwarden.service']
      maxretry = 3
    '';

    keycloak = ''
      enabled = true
      backend = systemd
      filter = keycloak[journalmatch='_SYSTEMD_UNIT=keycloak.service']
      maxretry = 3
    '';

    gitea = ''
      enabled = true
      backend = systemd
      filter = gitea[journalmatch='_SYSTEMD_UNIT=gitea.service']
      maxretry = 8
    '';
  };

  # Create some custom fail2ban filters.
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

    "fail2ban/filter.d/keycloak.conf".text = ''
      [Includes]
      before = common.conf

      # This is based from the server administration guide at
      # https://www.keycloak.org/docs/$VERSION/server_admin/index.html.
      [Definition]
      failregex = ^.*type=LOGIN_ERROR.*ipAddress=<HOST>.*$
      ignoreregex =
    '';

    "fail2ban/filter.d/gitea.conf".text = ''
      [Includes]
      before = common.conf

      # Thankfully, Gitea also has a dedicated page for configuring fail2ban
      # for the service at https://docs.gitea.io/en-us/fail2ban-setup/
      [Definition]
      failregex = ^.*(Failed authentication attempt|invalid credentials|Attempted access of unknown user).* from <HOST>
      ignoreregex =
    '';
  };

  # DNS-related settings. This is nice for automating them putting DNS records
  # and other types of stuff.
  security.acme.defaults = {
    dnsProvider = "porkbun";
    credentialsFile = config.sops.secrets."plover/lego/env".path;
  };

  services.openssh.hostKeys = [{
    path = config.sops.secrets."plover/ssh-key".path;
    type = "ed25519";
  }];

  # The main server where it will tie all of the services in one neat little
  # place.
  services.nginx = {
    enable = true;
    enableReload = true;

    package = pkgs.nginxMainline;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Server blocks with no forcing of SSL are static sites so it is pretty
    # much OK.
    virtualHosts = {
      # Vaultwarden instance.
      "${passwordManagerDomain}" = {
        forceSSL = true;
        enableACME = true;
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

      # Gitea instance.
      "${codeForgeDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.gitea.httpPort}";
        };
      };

      # Keycloak instance.
      "${authDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}";
        };
      };

      # Portunus server which also has an OpenLDAP server running.
      "${ldapDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.portunus.port}";
        };
      };

      # A nice little sync server for my shell history.
      "${atuinDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.atuin.port}";
        };
      };
    };
  };

  # Enable database services that is used in all of the services here so far.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;

    # Create per-user schema as documented from Usage Patterns. This is to make
    # use of the secure schema usage pattern they encouraged to do.
    #
    # Now, you just have to keep in mind about applications making use of them.
    # Most of them should have the setting to set the schema to be used. If
    # not, then screw them (or just file an issue and politely ask for the
    # feature).
    initialScript =
      let
        # This will be run once anyways so it is acceptable to create users
        # "forcibly".
        perUserSchemas = lib.lists.map
          (user: ''
            CREATE USER ${user.name};
            CREATE SCHEMA AUTHORIZATION ${user.name};
          '')
          config.services.postgresql.ensureUsers;
      in
      pkgs.writeText "plover-initial-postgresql-script" ''
        ${lib.concatStringsSep "\n" perUserSchemas}
      '';

    settings = {
      # Still doing the secure schema usage pattern.
      search_path = "\"$user\"";
    };

    # There's no database and user checks for Vaultwarden service.
    ensureDatabases = [ vaultwardenDbName keycloakDbName ];
    ensureUsers = [
      {
        name = vaultwardenUser;
        ensurePermissions = {
          "DATABASE ${vaultwardenDbName}" = "ALL PRIVILEGES";
          "SCHEMA ${vaultwardenDbName}" = "ALL PRIVILEGES";
        };
      }
      {
        name = config.services.gitea.user;
        ensurePermissions = {
          "SCHEMA ${config.services.gitea.user}" = "ALL PRIVILEGES";
        };
      }
      {
        name = keycloakUser;
        ensurePermissions = {
          "DATABASE ${keycloakDbName}" = "ALL PRIVILEGES";
          "SCHEMA ${keycloakDbName}" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.portunus = {
    enable = true;

    port = 8168;
    domain = ldapDomain;

    ldap = {
      searchUserName = "admin";
      suffix = "dc=foodogsquared,dc=one";
      tls = true;
    };

    seedPath = let
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
            posix_gid = 101;
          }
        ];
        users = [
          {
            login_name = "foodogsquared";
            given_name = "Gabriel";
            family_name = "Arazas";
            email = "foodogsquared@${domain}";
            ssh_public_keys = let
              readFiles = list: lib.lists.map (path: lib.readFile path) list;
            in readFiles [
              ../../users/home-manager/foo-dogsquared/files/ssh-key.pub
              ../../users/home-manager/foo-dogsquared/files/ssh-key-2.pub
            ];
            password.from_command = [ "${pkgs.coreutils}/bin/cat" config.sops.secrets."plover/ldap/users/foodogsquared/password".path ];
          }
        ];
      };
      settingsFormat = pkgs.formats.json { };
    in settingsFormat.generate "portunus-seed" seedData;
  };

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

  # With a database comes a dumping.
  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
    compressionLevel = 11;

    # Start at every 3 days starting from the first day of the month.
    startAt = "*-*-1/3";
  };

  # My code forge.
  services.gitea = {
    enable = true;
    appName = "foodogsquared's code forge";
    database = {
      type = "postgres";
      passwordFile = config.sops.secrets."plover/gitea/db/password".path;
    };
    domain = codeForgeDomain;
    rootUrl = "https://${codeForgeDomain}";

    # Allow Gitea to take a dump.
    dump = {
      enable = true;
      interval = "weekly";
    };

    # There are a lot of services in port 3000 so we'll change it.
    httpPort = 8432;
    lfs.enable = true;

    mailerPasswordFile = config.sops.secrets."plover/gitea/smtp/password".path;

    settings = {
      "repository.pull_request" = {
        WORK_IN_PROGRESS_PREFIXES = "WIP:,[WIP],DRAFT,[DRAFT]";
        ADD_CO_COMMITTERS_TRAILERS = true;
      };

      ui = {
        DEFAULT_THEME = "auto";
        EXPLORE_PAGING_SUM = 15;
        GRAPH_MAX_COMMIT_NUM = 200;
      };

      "ui.meta" = {
        AUTHOR = "foodogsquared's code forge";
        DESCRIPTION = "foodogsquared's personal projects and some archived and mirrored codebases.";
        KEYWORDS = "foodogsquared,gitea,self-hosted";
      };

      # It's a personal instance so nah...
      service.DISABLE_REGISTRATION = true;

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        DEFAULT_PRIVATE = "public";
        DEFAULT_PRIVATE_PUSH_CREATE = true;
      };

      "markup.asciidoc" = {
        ENABLED = true;
        NEED_POSTPROCESS = true;
        FILE_EXTENSIONS = ".adoc,.asciidoc";
        RENDER_COMMAND = "${pkgs.asciidoctor}/bin/asciidoctor --out-file=- -";
        IS_INPUT_FILE = false;
      };

      # Mailer service.
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtp+starttls";
        SMTP_ADDRESS = "smtp.sendgrid.net";
        SMTP_PORT = 587;
        USER = "apikey";
        FROM = "bot+gitea@foodogsquared.one";
        SEND_AS_PLAIN_TEXT = true;
        SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
      };

      # Well, collaboration between forges is nice...
      federation.ENABLED = true;

      # Enable mirroring feature...
      mirror.ENABLED = true;

      # Session configuration.
      session.COOKIE_SECURE = true;

      # Some more database configuration.
      database.SCHEMA = config.services.gitea.user;

      # Run various periodic services.
      "cron.update_mirrors".SCHEDULE = "@every 12h";

      other = {
        SHOW_FOOTER_VERSION = true;
        ENABLE_SITEMAP = true;
        ENABLE_FEED = true;
      };
    };
  };

  # Disk space is always assumed to be limited so we're really only limited with 2 dumps.
  systemd.services.gitea-dump.serviceConfig = {
    ExecStartPre = pkgs.writeShellScript "gitea-dump-limit" ''
      find ${config.services.gitea.dump.backupDir} -mtime 14 -maxdepth 1 -type f -delete
    '';
  };

  # An alternative implementation of Bitwarden written in Rust. The project
  # being written in Rust is a insta-self-hosting material right there.
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.secrets."plover/vaultwarden/env".path;
    config = {
      DOMAIN = "https://${passwordManagerDomain}";

      # Configuring the server.
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

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

  # Atuin sync server because why not.
  services.atuin = {
    enable = true;
    openFirewall = true;
    openRegistration = false;
    port = 8965;
  };

  systemd.services.atuin = {
    path = [ config.services.postgresql.package ];
    preStart = ''
      psql -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name='atuin';" \
        grep -q 1 || psql -tAc "CREATE SCHEMA IF NOT EXISTS atuin;"
    '';
  };

  # Of course, what is a server without a backup? A professionally-handled
  # production system. However, we're not professionals so we do have backups.
  services.borgbackup.jobs =
    let
      jobCommonSettings = { patternFiles ? [ ], patterns ? [ ], paths ? [ ], repo, passCommand }: {
        inherit paths repo;
        compression = "zstd,11";
        dateFormat = "+%F-%H-%M-%S-%z";
        doInit = true;
        encryption = {
          inherit passCommand;
          mode = "repokey-blake2";
        };
        extraCreateArgs =
          let
            args = lib.flatten [
              (builtins.map
                (patternFile: "--patterns-from ${lib.escapeShellArg patternFile}")
                patternFiles)
              (builtins.map
                (pattern: "--pattern ${lib.escapeShellArg pattern}")
                patterns)
            ];
          in
          lib.concatStringsSep " " args;
        extraInitArgs = "--make-parent-dirs";
        persistentTimer = true;
        preHook = ''
          extraCreateArgs="$extraCreateArgs --stats"
        '';
        prune.keep = {
          weekly = 4;
          monthly = 12;
          yearly = 6;
        };
        startAt = "monthly";
        environment.BORG_RSH = "ssh -i ${config.sops.secrets."plover/borg/ssh-key".path}";
      };

      borgRepo = path: "ssh://${hetzner-boxes-user}@${hetzner-boxes-server}:23/./borg/plover/${path}";
    in
    {
      # Backup for host-specific files. They don't change much so it is
      # acceptable for it to be backed up monthly.
      host-backup = jobCommonSettings {
        patternFiles = [
          config.sops.secrets."plover/borg/repos/host/patterns/keys".path
        ];
        repo = borgRepo "host";
        passCommand = "cat ${config.sops.secrets."plover/borg/repos/host/password".path}";
      };

      # Backups for various services.
      services-backup = jobCommonSettings
        {
          paths = [
            # Vaultwarden
            "/var/lib/bitwarden_rs"

            # Gitea
            config.services.gitea.dump.backupDir

            # PostgreSQL database dumps
            config.services.postgresqlBackup.location
          ];
          repo = borgRepo "services";
          passCommand = "cat ${config.sops.secrets."plover/borg/repos/services/password".path}";
        } // { startAt = "weekly"; };
    };

  programs.ssh.extraConfig = ''
    Host ${hetzner-boxes-server}
     IdentityFile ${config.sops.secrets."plover/borg/ssh-key".path}
  '';

  systemd.tmpfiles.rules =
    let
      # To be used similarly to $GITEA_CUSTOM variable.
      giteaCustomDir = "${config.services.gitea.stateDir}/custom";
    in
    [
      "L+ ${giteaCustomDir}/templates/home.tmpl - - - - ${./files/gitea/home.tmpl}"
      "L+ ${giteaCustomDir}/public/img/logo.svg - - - - ${./files/gitea/logo.svg}"
      "L+ ${giteaCustomDir}/public/img/logo.png - - - - ${./files/gitea/logo.png}"
    ];

  system.stateVersion = "22.11";
}
