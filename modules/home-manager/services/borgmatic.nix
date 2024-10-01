# A re-implementation of the Borgmatic service home-manager module. The
# reimplementation basically separates all of the configurations instead of a
# oneshot where it will execute Borgmatic with all present configurations
# (which is fine but too overwhelming for my taste).
#
# It has an added integration for individual Borgmatic configurations from
# `programs.borgmatic.backups` (also a reimplemented version from the upstream)
# to be added to the jobset and has more control over each service unit.
#
# As a design constraint, you should still be able to do what the upstream
# service module with a little bit of elbow grease.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.borgmatic;
  programCfg = config.programs.borgmatic;
  settingsFormat = pkgs.formats.yaml { };

  borgmaticProgramModule = { name, lib, ... }: {
    options = {
      initService = {
        enable = lib.mkEnableOption "include this particular backup as part of Borgmatic jobset at {option}`services.borgmatic.jobs`";

        startAt = lib.mkOption {
          type = lib.types.nonEmptyStr;
          description = ''
            Indicates how often the associated service occurs. Accepts value as
            found from {manpage}`systemd.time(7)`.
          '';
          default = "daily";
          example = "04:30";
        };
      };
    };
  };

  borgmaticJobModule = { config, lib, name, ... }: let
    settingsFile = settingsFormat.generate "borgmatic-job-config-${name}" config.settings;
  in {
    options = {
      settings = lib.mkOption {
        type = settingsFormat.type;
        description = ''
          Configuration settings associated with the job. If this is set, the
          generated output is added as an additional argument (i.e., `--config
          SETTINGSFILE`) in the service script.
        '';
        default = { };
        example = lib.literalExpression ''
          {
            source_directories = [
              config.xdg.userDirs.document
              config.xdg.userDirs.download
              config.xdg.userDirs.music
              config.xdg.userDirs.video
            ];

            keep_daily = 5;
            keep_weekly = 10;
            keep_monthly = 20;

            repositories = lib.singleton {
              path = "ssh://asodajdoiasjdoij";
              label = "remote";
            };
          }
        '';
      };

      startAt = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = ''
          Indicates how often backup will occur. This is to be used as value
          for `Timer.OnCalendar=` in the systemd unit. See
          {manpage}`systemd.time(7)` for more details.
        '';
        default = "daily";
        example = "04:30";
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          List of arguments to be passed to the Borgmatic backup service.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [
            "--stats"
            "--verbosity" "1"
            "--syslog-verbosity" "1"
            "--list"
          ]
        '';
      };
    };

    config = {
      extraArgs = lib.mkMerge [
        cfg.extraArgs

        (lib.optionals (config.settings != {}) (
          lib.mkBefore [
            "--config" settingsFile
          ]
        ))
      ];
    };
  };

  formatUnitName = name: "borgmatic-job-${name}";
  mkBorgmaticServiceUnit = n: v:
    lib.nameValuePair (formatUnitName n) {
      Unit = {
        Description = "Borgmatic backup job '${n}'";
        Documentation = [
          "https://torsion.org/borgmatic/docs/reference/configuration"
        ];
        ConditionACPower = true;
      };

      Service = {
        # TODO: Just cargo-culted from the upstream home-manager module. Will
        # need more info on this.
        Nice = 19;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
        IOWeight = 100;

        Restart = "on-failure";
        LogRateLimitIntervalSec = 0;

        ExecStart = ''
          ${lib.getExe' cfg.package "borgmatic"} ${lib.concatStringsSep " " v.extraArgs}
        '';

        PrivateTmp = true;
      };
    };

  mkBorgmaticTimerUnit = n: v:
    lib.nameValuePair (formatUnitName n) {
      Unit.Description = "Borgmatic backup job '${n}'";

      Timer = {
        OnCalendar = v.startAt;
        Persistent = lib.mkDefault true;
        RandomizedDelaySec = lib.mkDefault "10m";
      };

      Install.WantedBy = [ "timers.target" ];
    };

  mkBorgmaticServiceFromConfig = n: v:
    lib.nameValuePair "borgmatic-config-${n}" {
      inherit (v.initService) startAt;
      extraArgs = [
        "--config" "${config.xdg.configHome}/borgmatic.d/${n}"
      ];
    };
in
{
  disabledModules = [ "services/borgmatic.nix" ];
  options.programs.borgmatic.backups = lib.mkOption {
    type = with lib.types; attrsOf (submodule borgmaticProgramModule);
  };

  options.services.borgmatic = {
    package = lib.mkPackageOption pkgs "borgmatic" { };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Global list of additional arguments for all of the jobs.
      '';
      default = [ ];
      example = [
        "--stats"
        "--verbosity" "1"
      ];
    };

    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule borgmaticJobModule);
      default = { };
        example = lib.literalExpression ''
          {
            personal = {
              startAt = "05:30";
              settings = {
                source_directories = [
                  "''${config.xdg.configHome}"
                  "''${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}"
                  "''${config.home.homeDirectory}/.thunderbird"
                  "''${config.home.homeDirectory}/Zotero"
                ];

                repositories = [
                  {
                    path = "ssh://k8pDxu32@k8pDxu32.repo.borgbase.com/./repo";
                    label = "borgbase";
                  }

                  {
                    path = "/var/lib/backups/local.borg";
                    label = "local";
                  }
                ];

                keep_daily = 7;
                keep_weekly = 4;
                keep_monthly = 6;
              };
            };
          }
        '';
      };
    };

  config = {
    systemd.user.services =
      lib.mapAttrs' mkBorgmaticServiceUnit cfg.jobs;

    systemd.user.timers =
      lib.mapAttrs' mkBorgmaticTimerUnit cfg.jobs;

    services.borgmatic.jobs =
      let
        validService = lib.filterAttrs (n: v: v.initService.enable) programCfg.backups;
      in
      lib.mapAttrs' mkBorgmaticServiceFromConfig validService;
  };
}
