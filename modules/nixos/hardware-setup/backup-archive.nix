# This is my external hard drive.
{ config, options, lib, pkgs, ... }:

# TODO: Make this a generic service.
#       There are multiple external storage drives now.
let
  cfg = config.modules.hardware-setup.backup-archive;
in {
  options.modules.hardware-setup.backup-archive.enable = lib.mkEnableOption "external hard drive and automated backup service with BorgBackup";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = config.modules.agenix.enable;
      message = "Agenix module is not enabled.";
    }];

    age.secrets.external-backup-borgmatic-settings.file = lib.getSecret "archive/password";
    fileSystems."/mnt/external-storage" = {
      device = "/dev/disk/by-uuid/665A391C5A38EB07";
      fsType = "ntfs";
      noCheck = true;
      options = [
        "nofail"
        "noauto"
        "user"

        # See systemd.mount.5 and systemd.automount.5 manual page for more
        # details.
        "x-systemd.automount"
        "x-systemd.device-timeout=2"
        "x-systemd.idle-timeout=2"
      ];
    };

    systemd.services.borgmatic-external-archive = {
      unitConfig = {
        Description = "Backup with Borgmatic";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
        ConditionACPower = true;
      };

      startAt = "04/3:00:00";
      serviceConfig = {
        # Delay start to prevent backups running during boot. Note that systemd-inhibit requires dbus and
        # dbus-user-session to be installed.
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1m";
        ExecStart = ''
          ${pkgs.systemd}/bin/systemd-inhibit --who="borgmatic" --why="Prevent interrupting scheduled backup" ${pkgs.borgmatic}/bin/borgmatic --verbosity -1 --syslog-verbosity 1 --config ${config.age.secrets.external-backup-borgmatic-settings.path}
        '';

        # Set security-related stuff.
        LockPersonality = "true";
        ProtectSystem = "full";
        MemoryDenyWriteExecute = "no";
        NoNewPrivileges = "yes";
        PrivateDevices= "yes";
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

        Restart = "no";

        # Prevent rate limiting of borgmatic log events. If you are using an older version of systemd that
        # doesn't support this (pre-240 or so), you may have to remove this option.
        LogRateLimitIntervalSec = "0";
      };
    };
  };
}
