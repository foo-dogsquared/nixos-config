{ config, options, lib, pkgs, ... }:

let
  cfg = config.profiles.filesystem;
in {
  options.profiles.filesystem = {
    archive.enable = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Add the archive storage to the list of filesystems.
      '';
      default = false;
    };

    external-hdd.enable = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Add the external hard drive to the list of filesystems.
      '';
      default = false;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.archive.enable {
      fileSystems."/mnt/archives" = {
        device = "/dev/disk/by-uuid/6ba86a30-5fa4-41d9-8354-fa8af0f57f49";
        fsType = "btrfs";
        noCheck = true;
        options = [
          # These are btrfs-specific mount options which can found in btrfs.5
          # manual page.
          "subvol=@"
          "noatime"
          "compress=zstd:9"
          "space_cache=v2"

          # General mount options from mount.5 manual page.
          "noauto"
          "nofail"
          "user"

          # See systemd.mount.5 and systemd.automount.5 manual page for more
          # details.
          "x-systemd.automount"
          "x-systemd.idle-timeout=2"
          "x-systemd.device-timeout=2"
        ];
      };
    })

    (lib.mkIf cfg.external-hdd.enable {
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
    })
  ];
}
