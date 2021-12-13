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

    age.secrets.archive-password.file = ../../../secrets/archive/password;
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

    services.borgbackup.jobs.external-storage = {
      dateFormat = "+%F-%H-%M-%S-%z";
      doInit = false;
      removableDevice = true;
      paths = [
        "/home/*/.config/environment.d"
        "/home/*/.config/systemd"
        "/home/*/.gnupg"
        "/home/*/.password-store"
        "/home/*/.ssh"
        "/home/*/.thunderbird"
        "/home/*/dotfiles"
        "/home/*/library"
      ];
      exclude = [
        "*/.cache"
        "*.pyc"
        "*/node_modules"
        "*/.next"
        "*/result"
        "projects/software/*/build"
        "projects/software/*/target"
      ];
      repo = "/mnt/external-storage/backups";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.archive-password.path}";
      };
      compression = "lz4";
      prune = {
        prefix = "{hostname}-";
        keep = {
          within = "1w"; # Keep all archives from the last week.
          daily = 30;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month.
          yearly = 3;
        };
      };
      startAt = "04/8:00:00"; # Every 8 hours starting at 04:00.
    };
  };
}
