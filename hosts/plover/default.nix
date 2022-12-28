{ config, options, lib, pkgs, modulesPath, ... }:

let
  inherit (builtins) toString;

  domain = config.networking.domain;
  subdomain = prefix: "${prefix}.${domain}";

  passwordManagerDomain = subdomain "pass";
  codeForgeDomain = subdomain "code";
  authDomain = subdomain "auth";
  ldapDomain = subdomain "ldap";

  certs = config.security.acme.certs;

  # This should be set from service module from nixpkgs.
  vaultwardenUser = config.users.users.vaultwarden.name;

  # However, this is set on our own.
  vaultwardenDbName = "vaultwarden";

  # This is also set on our own.
  keycloakUser = config.services.keycloak.database.username;
  keycloakDbName = if config.services.keycloak.database.createLocally then keycloakUser else config.services.keycloak.database.username;

  # The head of the Borgbase hostname.
  borgbase-remote = "cr6pf13r";
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

  networking = {
    domain = "foodogsquared.one";
    firewall.allowedTCPPorts = [
      22 # Secure Shells.
      80 # HTTP servers.
      433 # HTTPS servers.

      389 # LDAP servers.
      636 # LDAPS servers.
    ];
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
      "borg/patterns/keys" = { };
      "borg/password" = { };
      "keycloak/db/password".owner = postgresUserGroup;
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

  # DNS-related settings. This is nice for automating them putting DNS records
  # and other types of stuff.
  security.acme = {
    defaults = {
      dnsProvider = "porkbun";
      credentialsFile = config.sops.secrets."plover/lego/env".path;
    };

    certs = {
      "${ldapDomain}".group = config.services.openldap.group;
    };
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
        locations = let
          keycloakPath = path: "http://localhost:${toString config.services.gitea.httpPort}${path}";
        in {
          "/realms".proxyPass = keycloakPath "/realms";
          "/resources".proxyPass = keycloakPath "/resources";
          "/robots.txt".proxyPass = keycloakPath "/robots.txt";
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
      in pkgs.writeText "plover-initial-postgresql-script" ''
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

  # How to overkill your multi-purpose single-user-oriented server that is
  # typically accessed from the web with a single step.
  services.openldap = let
    openldapPackage = config.services.openldap.package;
  in {
    enable = true;

    mutableConfig = true;

    urlList = [ "ldap:///" "ldaps:///" "ldapi://" ];

    settings = {
      attrs = {
        olcLogLevel = [ "stats" ];
        olcTLSCACertificateFile = "${certs.${ldapDomain}.directory}/fullchain.pem";
        olcTLSCertificateFile = "${certs.${ldapDomain}.directory}/chain.pem";
        olcTLSCertificateKeyFile = "${certs.${ldapDomain}.directory}/key.pem";
      };

      children = {
        "olcDatabase={-1}frontend".attrs = {
          objectClass = "olcDatabaseConfig";
          olcDatabase = "{-1}frontend";
          olcAccess = [ "{0}to * by dn.exact=uidNumber=0+gidNumber=0,cn=peercred,cn=external,cn=auth manage stop by * none stop" ];
        };

        "olcDatabase={0}config".attrs = {
          objectClass = "olcDatabaseConfig";
          olcDatabase = "{0}config";
          olcAccess = [ "{0}to * by * none break" ];
        };

        "olcDatabase={1}mdb".attrs = {
          objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/ldap";
          olcDbIndex = [
            "objectClass eq"
            "cn pres,eq"
            "uid pres,eq"
            "sn pres,eq,subany"
          ];
          olcSuffix = "dc=foodogsquared,dc=one";
          olcRootDN = "cn=Manager,dc=foodogsquared,dc=one";
          olcAccess = [ "{0}to * by * read break" ];
        };

        "cn=schema".includes = [
          "${openldapPackage}/etc/schema/core.ldif"
          "${openldapPackage}/etc/schema/cosine.ldif"
          "${openldapPackage}/etc/schema/inetorgperson.ldif"
        ];
      };
    };
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
      interval = "Sunday";
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

      # Configuring the database. Take note it is required to create a password
      # for the user.
      DATABASE_URL = "postgresql://${vaultwardenUser}@/${vaultwardenDbName}";

      # Mailer service configuration (except the user and password).
      SMTP_HOST = "smtp.sendgrid.net";
      SMTP_PORT = 587;
      SMTP_FROM_NAME = "Vaultwarden";
      SMTP_FROM = "bot+vaultwarden@foodogsquared.one";
    };
  };

  # Of course, what is a server without a backup? A professionally-handled
  # production system. However, we're not professionals so we do have backups.
  services.borgbackup.jobs =
    let
      jobCommonSettings = { patternFiles ? [ ], patterns ? [ ], paths ? [ ] }: {
        inherit paths;
        compression = "zstd,11";
        dateFormat = "+%F-%H-%M-%S-%z";
        doInit = true;
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${config.sops.secrets."plover/borg/password".path}";
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
        repo = "${borgbase-remote}@${borgbase-remote}.repo.borgbase.com:repo";
        startAt = "monthly";
        environment.BORG_RSH = "ssh -i ${config.sops.secrets."plover/ssh-key".path}";
      };
    in
    {
      # Backup for host-specific files. They don't change much so it is
      # acceptable for it to be backed up monthly.
      host-backup = jobCommonSettings {
        patternFiles = [
          config.sops.secrets."plover/borg/patterns/keys".path
        ];
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
        } // { startAt = "weekly"; };
    };

  programs.ssh.extraConfig = ''
    Host ${borgbase-remote}.repo.borgbase.com
     IdentityFile ${config.sops.secrets."plover/ssh-key".path}
  '';

  systemd.tmpfiles.rules = let
    # To be used similarly to $GITEA_CUSTOM variable.
    giteaCustomDir = "${config.services.gitea.stateDir}/custom";
  in [
    "L+ ${giteaCustomDir}/templates/home.tmpl - - - - ${./files/gitea/home.tmpl}"
    "L+ ${giteaCustomDir}/public/img/logo.svg - - - - ${./files/gitea/logo.svg}"
    "L+ ${giteaCustomDir}/public/img/logo.png - - - - ${./files/gitea/logo.png}"
  ];

  system.stateVersion = "22.11";
}
