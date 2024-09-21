# A bunch of predefined filesystem configurations for several devices. This is
# nice for setting up shop for certain tasks with the flick of the switch to ON
# (e.g., `config.suites.filesystem.archive.enable = true`) and not have
# conflicting settings all throughout the configuration.
#
# Much of the filesystem setups are taking advantage of systemd's fstab
# extended options which you can refer to at systemd.mount(5), mount(5), and
# the filesystems' respective manual pages.
{ config, lib, pkgs, ... }:

let
  cfg = config.suites.filesystem;
in
{
  options.suites.filesystem = {
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
        ntfs3g
      ];
    })

    (lib.mkIf cfg.setups.archive.enable {
      state.paths.archive = "/mnt/archives";

      fileSystems."${config.state.paths.archive}" = {
        device = "/dev/disk/by-partlabel/disk-archive-root";
        fsType = "btrfs";
        noCheck = true;
        options = [
          # These are btrfs-specific mount options which can found in btrfs.5
          # manual page.
          "subvol=/root"
          "noatime"
          "compress=zstd:6"

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
      state.paths.external-hdd = "/mnt/external-storage";

      fileSystems."${config.state.paths.external-hdd}" = {
        device = "/dev/disk/by-partlabel/disk-live-installer-root";
        fsType = "btrfs";
        noCheck = true;
        options = [
          "nofail"
          "noauto"
          "user"

          "subvol=/data"
          "compress=zstd"
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
