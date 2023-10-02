# A bunch of predefined filesystem configurations for several devices. This is
# nice for setting up shop for certain tasks with the flick of the switch to ON
# (e.g., `config.profiles.filesystem.archive.enable = true`) and not have
# conflicting settings all throughout the configuration.
#
# Much of the filesystem setups are taking advantage of systemd's fstab
# extended options which you can refer to at systemd.mount(5), mount(5), and
# the filesystems' respective manual pages.
{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.filesystem;
in
{
  options.profiles.filesystem = {
    tools.enable = lib.mkEnableOption "filesystem-related settings";
    setups = {
      archive.enable = lib.mkEnableOption "automounting offline archive";
      external-hdd.enable = lib.mkEnableOption "automounting personal external hard drive";
      personal-webstorage.enable = lib.mkEnableOption "automounting of personal WebDAV directory";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.tools.enable {
      # Enable WebDAV mounting.
      services.davfs2.enable = true;

      # Installing filesystem debugging utilities.
      environment.systemPackages = with pkgs; [
        afuse
      ];
    })

    (lib.mkIf cfg.setups.archive.enable {
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

          "noauto"
          "nofail"
          "user"

          "x-systemd.automount"
          "x-systemd.idle-timeout=2"
          "x-systemd.device-timeout=2"
        ];
      };
    })

    (lib.mkIf cfg.setups.external-hdd.enable {
      fileSystems."/mnt/external-storage" = {
        device = "/dev/disk/by-uuid/665A391C5A38EB07";
        fsType = "ntfs";
        noCheck = true;
        options = [
          "nofail"
          "noauto"
          "user"

          "x-systemd.automount"
          "x-systemd.device-timeout=2"
          "x-systemd.idle-timeout=2"
        ];
      };
    })

    (lib.mkIf cfg.setups.personal-webstorage.enable {
      assertions = [{
        assertion = config.services.davfs2.enable;
        message = ''
          Mounting WebDAVs is not possible since davfs2 NixOS service is not
          enabled.
        '';
      }];

      # You have to set up the secrets for this somewhere.
      fileSystems."/mnt/personal-webdav" = {
        device = "https://dav.mailbox.org/servlet/webdav.infostore";
        fsType = "davfs";
        noCheck = true;
        options = [
          "rw"
          "user"
          "noauto"
          "nofail"

          "x-systemd.automount"
          "x-systemd.idle-timeout=300"
          "x-systemd.mount-timeout=20"
          "x-systemd.wanted-by=multi-user.target"
        ];
      };
    })
  ];
}
