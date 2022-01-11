# An improved version of the borgmatic module.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.borgmatic;

  jobOption = { name, config, ... }: {
    options = {
      startAt = lib.mkOption {
        type = lib.types.str;
        description = ''
          The schedule for the backup. It uses the time format from <literal>systemd.time</literal>.
        '';
        default = "daily";
        example = "04/8:00:00";
      };

      configPath = lib.mkOption {
        type = lib.types.path;
        description = ''
          The path of the configuration file to be used. For a start, you can quickly create a template by running <literal>generate-borgmatic-config</literal>.
        '';
        example = "./personal-drive.yaml";
      };

      doPrune = lib.mkEnableOption "pruning the backup";
    };
  };
in {
  options.services.borgmatic = {
    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule jobOption);
      description =
        "borgmatic jobs with each bearing a configuration file to be used.";
      default = { };
      example = {
        external-hard-drive = {
          startAt = "daily";
          configPath = ./borgmatic.yaml;
        };
      };
    };
  };

  config = {
    systemd.services = (lib.mapAttrs' (name: settings:
      lib.nameValuePair ("borgmatic-backup-" + name) ({
        unitConfig = {
          Description = "Backup with Borgmatic job '${name}'";
          Wants = [ "network-online.target" ];
          After = [ "network-online.target" ];
        };

        startAt = settings.startAt;
        serviceConfig = {
          # Delay start to prevent backups running during boot. Note that systemd-inhibit requires dbus and
          # dbus-user-session to be installed.
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 1m";
          ExecStart = ''
            ${pkgs.systemd}/bin/systemd-inhibit --who="borgmatic" --why="Prevent interrupting scheduled backup" ${pkgs.borgmatic}/bin/borgmatic --verbosity -1 --syslog-verbosity 1 --config ${settings.configPath}
          '';

          # Set security-related stuff.
          LockPersonality = "true";
          ProtectSystem = "full";
          MemoryDenyWriteExecute = "no";
          NoNewPrivileges = "yes";
          PrivateDevices = "yes";
          PrivateTmp = "yes";
          ProtectClock = "yes";
          ProtectControlGroups = "yes";
          ProtectHostname = "yes";
          ProtectKernelLogs = "yes";
          ProtectKernelModules = "yes";
          ProtectKernelTunables = "yes";
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
          RestrictNamespaces = "yes";
          RestrictRealtime = "yes";
          RestrictSUIDSGID = "yes";
          SystemCallArchitectures = "native";
          SystemCallFilter = "@system-service";
          SystemCallErrorNumber = "EPERM";
          CapabilityBoundingSet = "CAP_DAC_READ_SEARCH CAP_NET_RAW";

          # Lower CPU and I/O priority.
          Nice = 19;
          CPUSchedulingPolicy = "batch";
          IOSchedulingClass = "best-effort";
          IOSchedulingPriority = 7;
          IOWeight = 100;

          # Prevent rate limiting of borgmatic log events. If you are using an older version of systemd that
          # doesn't support this (pre-240 or so), you may have to remove this option.
          LogRateLimitIntervalSec = "0";
        };
      })) cfg.jobs);
  };
}
