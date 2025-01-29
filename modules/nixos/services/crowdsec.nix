{ config, lib, pkgs, ... }:

let
  cfg = config.services.crowdsec;

  settingsFormat = pkgs.formats.yaml { };

  settingsSubmodule = { lib, ... }: {
    freeformType = settingsFormat.type;

    # Set all of the related Crowdsec configuration options from the user-given
    # service module config.
    config = lib.mkMerge [
      (let
        plugins =
          lib.filterAttrs (n: v: v.package != null) cfg.notificationPlugins;
      in lib.mkIf (plugins != { }) {
        config_paths.plugin_dir = lib.mkDefault pluginsDir;
      })

      (let
        pluginsSettings =
          lib.filterAttrs (n: v: v.settings != { }) cfg.notificationPlugins;
      in lib.mkIf (pluginsSettings != { }) {
        config_paths.notification_dir = lib.mkDefault pluginsConfigDrv;
      })

      (lib.mkIf (cfg.dataSources != { }) {
        crowdsec_service.acqusition_dir = lib.mkDefault acqusitionsDir;
      })
    ];
  };

  pluginsDir = pkgs.symlinkJoin {
    name = "crowdsec-system-notification-plugins";
    paths = let
      plugins =
        lib.filterAttrs (n: v: v.package != null) cfg.notificationPlugins;
    in lib.mapAttrsToList (n: v: "${v.package}/share/crowdsec") plugins;
  };

  pluginsConfigDrv = let
    pluginsConfigs = lib.mapAttrsToList (n: v:
      settingsFormat.generate "crowdsec-system-plugin-config-${n}" v.settings)
      cfg.notificationPlugins;
  in pkgs.symlinkJoin {
    name = "crowdsec-system-notification-plugins-configs";
    paths = pluginsConfigs;
  };

  acqusitionsDir = let
    acqusitionConfigs = lib.mapAttrsToList (n: v:
      settingsFormat.generate "crowdsec-system-acqusition-config-${n}"
      v.settings) cfg.dataSources;
  in pkgs.symlinkJoin {
    name = "crowdsec-system-acqusitions-configs";
    paths = acqusitionConfigs;
  };

  crowdsecPluginsModule = { name, config, ... }: {
    options = {
      settings = lib.mkOption {
        type = settingsFormat.type;
        description = ''
          Configuration settings associated with the plugin.

          ::: {.caution}
          This setting is effectively ignored if
          {option}`services.crowdsec.settings.config_paths.notification_dir` is
          set manually.
          :::
        '';
        default = { };
        example = {
          type = "http";
          log_level = "info";
        };
      };

      package = lib.mkOption {
        type = with lib.types; nullOr package;
        description = ''
          Derivation containing a Crowdsec plugin at `$out/share/crowdsec`.
        '';
        default = null;
        example = lib.literalExpression "pkgs.crowdsec-slack-notification";
      };
    };
  };

  acqusitionsSubmodule = { name, config, ... }: {
    options.settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        Configuration associated with each data source.
      '';
      default = { };
      example = {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=ssh.service" ];
      };
    };
  };

  configFile = settingsFormat.generate "crowdsec-config" cfg.settings;
in {
  options.services.crowdsec = {
    enable = lib.mkEnableOption
      "[Crowdsec](https://crowdsec.net), a monitoring service using crowdsourced data";

    package = lib.mkPackageOption pkgs "crowdsec" { };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Extra arguments to be passed to the Crowdsec service.
      '';
      default = [ ];
      example = [ "-warning" ];
    };

    settings = lib.mkOption {
      type = lib.types.submodule settingsSubmodule;
      description = ''
        Configuration settings to be used with the service.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          common = {
            daemonize = false;
            log_media = "stdout";
          }
        }
      '';
    };

    notificationPlugins = lib.mkOption {
      type = with lib.types; attrsOf (submodule crowdsecPluginsModule);
      description = ''
        Set of Crowdsec notification plugins and their configuration (if
        given).
      '';
      default = { };
      example = lib.literalExpression ''
        {
          http = {
            settings = {
              type = "http";
              log_level = "info";
            };
          };

          slack = {
            package = pkgs.crowdsec-slack-notification;
            settings = {
              type = "";
              log_level = "info";
            };
          };
        }
      '';
    };

    dataSources = lib.mkOption {
      type = with lib.types; attrsOf (submodule acqusitionsSubmodule);
      description = ''
        Set of data sources where logs are to be analyzed from.

        ::: {.caution}
        This is to be included as part of the default acqusition configuration
        directory.

        If {option}`services.crowdsec.settings.crowdsec_agent.acqusition_dir`
        is set by the user, this option is effectively ignored.
        :::
      '';
      default = { };
      example = {
        ssh = {
          source = "journalctl";
          journalctl_filter = [ "_SYSTEMD_UNIT=ssh.service" ];
          labels.type = "syslog";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.crowdsec = {
      description = "Crowdsec monitoring server";
      script = ''
        ${lib.getExe' cfg.package "crowdsec"} -c ${configFile} ${
          lib.escapeShellArgs cfg.extraArgs
        }
      '';
      after = [
        "syslog.target"
        "network-online.target"
        "remote-fs.target"
        "nss-lookup.target"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecReload = "kill -HUP $MAINPID";
        ReadWritePaths =
          lib.optionals (cfg.settings.common.log_media or "" == "file")
          [ cfg.settings.common.log_folder ];

        User = "crowdsec";
        Group = "crowdsec";

        # TODO: Ideally, this should be set conditionally.
        # To enable access to systemd journal files.
        SupplementaryGroups = [ "systemd-journal" ];
        DynamicUser = true;

        Type = "notify";
        Restart = "always";
        RestartSec = "60";

        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        PrivateMounts = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RemoveIPC = true;
        StandardOutput = "journal";
        StandardError = "journal";
        SystemCallFilter = [ "@system-service" ];
        SystemCallErrorNumber = "EPERM";

        RestrictAddressFamilies = [ "AF_LOCAL" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictSUIDGUID = true;
        MemoryDenyWriteExecute = true;
      };
    };
  };
}
