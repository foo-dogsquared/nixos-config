{ config, lib, pkgs, ... }:

let
  cfg = config.services.crowdsec;

  settingsFormat = pkgs.formats.yaml { };

  settingsSubmodule = { lib, ... }: {
    freeformType = settingsFormat.type;
    options.config_paths = {
      notification_dir = lib.mkOption {
        type = lib.types.path;
        description = ''
          Directory where configuration files of notification plugins are kept.
        '';
        default = pluginsConfigDrv;
        defaultText = ''
          All of the compiled configuration files from
          {option}`services.crowdsec.plugins.settings`.
        '';
        example = "./config/crowdsec/plugins";
      };

      plugin_dir = lib.mkOption {
        type = lib.types.path;
        description = ''
          Directory where plugin executables are kept.
        '';
        default = pluginsDir;
        defaultText = ''
          All of the compiled plugins from
          {options}`services.crowdsec.plugins.package`.
        '';
      };
    };
  };

  pluginsDir = pkgs.symlinkJoin {
    name = "crowdsec-system-plugins";
    paths = lib.mapAttrsToList (n: v: "${v.package}/share/crowdsec") cfg.plugins;
  };

  pluginsConfigDrv = let
    pluginsConfigs =
      lib.mapAttrsToList
        (n: v:
          pkgs.writeTextDir "/notifications/${n}.yaml" (lib.generators.toYAML { } v.settings))
        cfg.plugins;
  in pkgs.symlinkJoin {
    name = "crowdsec-system-plugins-configs";
    paths = pluginsConfigs;
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
          set.
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

  configFile = settingsFormat.generate "crowdsec-config" cfg.settings;
in
{
  options.services.crowdsec = {
    enable = lib.mkEnableOption "[Crowdsec](https://crowdsec.net), a monitoring service using crowdsourced data";

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

    plugins = lib.mkOption {
      type = with lib.types; attrsOf (submodule crowdsecPluginsModule);
      description = ''
        Set of Crowdsec plugins and their configuration (if given).
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
  };

  config = lib.mkIf cfg.enable {
    systemd.services.crowdsec = {
      description = "Crowdsec monitoring server";
      script = ''
        ${lib.getExe' cfg.package "crowdsec"} -c ${configFile} ${lib.escapeShellArgs cfg.extraArgs}
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
        ReadWritePaths =
          lib.optionals (cfg.settings.common.log_media or "" == "file") [
            cfg.settings.common.log_folder
          ];

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
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";

        RestrictAddressFamilies = [
          "AF_LOCAL"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictSUIDGUID = true;
        MemoryDenyWriteExecute = true;
      };
    };
  };
}
