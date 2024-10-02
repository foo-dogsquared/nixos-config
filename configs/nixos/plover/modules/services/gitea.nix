# My code forge service of choice. I'm pretty excited for the federation
# feature in particular to see how this plays out. It might not be toppling
# over the popular services but it is interesting to see new spaces for this
# one.
{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.gitea;
  codeForgeDomain = "code.${config.networking.domain}";

  giteaUser = config.users.users."${config.services.gitea.user}".name;
in
{
  options.hosts.plover.services.gitea.enable =
    lib.mkEnableOption "Gitea server for ${config.networking.domain}";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      sops.secrets = foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
        "gitea/smtp_password".owner = giteaUser;
      };

      state.ports.gitea.value = 8432;

      services.gitea = {
        enable = true;
        appName = "foodogsquared's code forge";

        # Allow Gitea to take a dump.
        dump = {
          enable = true;
          interval = "weekly";
        };

        # There are a lot of services in port 3000 so we'll change it.
        lfs.enable = true;

        mailerPasswordFile = config.sops.secrets."gitea/smtp_password".path;

        # You can see the available configuration options at
        # https://docs.gitea.io/en-us/config-cheat-sheet/.
        settings = {
          server = {
            ROOT_URL = "https://${codeForgeDomain}";
            HTTP_PORT = config.state.ports.gitea.value;
            DOMAIN = codeForgeDomain;
          };

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
            RENDER_COMMAND = "${pkgs.asciidoctor}/bin/asciidoctor --embedded --out-file=- -";
            IS_INPUT_FILE = false;
          };

          # Mailer service.
          mailer = {
            ENABLED = true;
            PROTOCOL = "smtp+starttls";
            SMTP_ADDRESS = "mail.foodogsquared.one";
            SMTP_PORT = 587;
            USER = "bot@foodogsquared.one";
            FROM = "bot+gitea@foodogsquared.one";
            SEND_AS_PLAIN_TEXT = true;
            SENDMAIL_PATH = lib.getExe' pkgs.system-sendmail "sendmail";
          };

          # Reduce the logs to be filled with. You also have to keep in mind this
          # to be configured with fail2ban.
          log.LEVEL = "Warn";

          # Well, collaboration between forges is nice...
          federation.ENABLED = true;

          # Enable mirroring feature...
          mirror.ENABLED = true;

          # Session configuration.
          session.COOKIE_SECURE = true;

          # Some more database configuration.

          # Run various periodic services.
          "cron.update_mirrors".SCHEDULE = "@every 3h";

          other = {
            SHOW_FOOTER_VERSION = true;
            ENABLE_SITEMAP = true;
            ENABLE_FEED = true;
          };
        };
      };

      # Disk space is always assumed to be limited so we're really only limited
      # with 2 dumps.
      systemd.services.gitea-dump.preStart = lib.mkAfter ''
        ${pkgs.findutils}/bin/find ${lib.escapeShellArg config.services.gitea.dump.backupDir} \
          -maxdepth 1 -type f -iname '*.${config.services.gitea.dump.type}' -ctime 21 \
          | tail -n -3 | xargs rm
      '';

      # Customizing Gitea which you can see more details at
      # https://docs.gitea.io/en-us/customizing-gitea/. We're just using
      # systemd-tmpfiles to make this work which is pretty convenient.
      systemd.tmpfiles.rules =
        let
          # To be used similarly to $GITEA_CUSTOM variable.
          giteaCustomDir = config.services.gitea.customDir;
        in
        [
          "L+ ${giteaCustomDir}/templates/home.tmpl - - - - ${../../files/gitea/home.tmpl}"
          "L+ ${giteaCustomDir}/public/img/logo.svg  - - - - ${../../files/gitea/logo.svg}"
          "L+ ${giteaCustomDir}/public/img/logo.png  - - - - ${../../files/gitea/logo.png}"
        ];
    }

    (lib.mkIf hostCfg.services.database.enable {
      sops.secrets = foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
        "gitea/db_password".owner = giteaUser;
      };

      services.gitea.database = {
        type = "postgres";
        passwordFile = config.sops.secrets."gitea/db_password".path;
        port = config.state.ports.postgresql.value;
      };

      services.gitea.settings.database = {
        SCHEMA = config.services.gitea.user;
      };

      # Making sure this plays nicely with the database service of choice. Take
      # note, we're mainly using secure schema usage pattern here as described from
      # the PostgreSQL documentation at
      # https://www.postgresql.org/docs/15/ddl-schemas.html#DDL-SCHEMAS-PATTERNS.
      services.postgresql = {
        ensureDatabases = [ config.services.gitea.user ];
        ensureUsers = lib.singleton {
          name = config.services.gitea.user;
          ensureDBOwnership = true;
        };
      };
    })

    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      # Attaching it altogether with the reverse proxy of choice.
      services.nginx.virtualHosts."${codeForgeDomain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        kTLS = true;
        locations."/" = {
          proxyPass = "http://gitea";
        };
        extraConfig = ''
          proxy_cache ${config.services.nginx.proxyCachePath.apps.keysZoneName};
        '';
      };

      services.nginx.upstreams."gitea" = {
        extraConfig = ''
          zone services;
        '';
        servers = {
          "localhost:${builtins.toString config.services.gitea.settings.server.HTTP_PORT}" = { };
        };
      };
    })

    (lib.mkIf hostCfg.services.fail2ban.enable {
      # Configuring fail2ban for this service which thankfully has a dedicated page
      # at https://docs.gitea.io/en-us/fail2ban-setup/.
      services.fail2ban.jails = {
        gitea.settings = {
          enabled = true;
          backend = "systemd";
          filter = "gitea[journalmatch='_SYSTEMD_UNIT=gitea.service + _COMM=gitea']";
          maxretry = 8;
        };
      };

      environment.etc = {
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
    })

    (lib.mkIf hostCfg.services.backup.enable {
      # Add the following files to be backed up.
      services.borgbackup.jobs.services-backup.paths = [ config.services.gitea.dump.backupDir ];
    })
  ]);
}
