# This is my external hard drive.
{ config, options, lib, pkgs, ... }:

# TODO: Make this a generic service.
#       There are multiple external storage drives now.
let cfg = config.hardware-setup.backup-archive;
in {
  options.hardware-setup.backup-archive.enable = lib.mkEnableOption
    "external hard drive and automated backup service with BorgBackup";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = config.profiles.agenix.enable;
      message = "Agenix module is not enabled.";
    }];

    age.secrets.external-backup-borgmatic-settings.file =
      lib.getSecret "archive/borgmatic.json";

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

    # This uses the custom borgmatic NixOS service.
    services.borgmatic.jobs.external-storage = {
      startAt = "04/6:00:00";
      configPath = config.age.secrets.external-backup-borgmatic-settings.path;
    };
  };
}
