# A set of tools related to files: managing metadata, backing them up, filesystems, and whatnot.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.files;
in {
  options.modules.desktop.files = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      exfat                 # A filesystem usually found on external hard drives.
      exiftool              # A file metadata reader/writer/manager/helicopter.
      hfsprogs              # Some programs for HFS/NFS-based filesystems.
      ntfs3g                # A filesystem for Windows-based systems.
      syncthing             # A peer-to-peer synchro summoning.
      xfce.thunar           # A graphical file manager.
      xfce.thunar-volman    # A Thunar plugin on volume management for external devices.
      udiskie               # An automounter for external devices with authentication.
    ];
  };
}
