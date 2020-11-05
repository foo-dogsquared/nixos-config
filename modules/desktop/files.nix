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
    my.packages = with pkgs; [
      exiftool # A file metadata reader/writer/manager/helicopter.
      (recoll.override {
        withGui = false;
      }) # Bring the search engine to the desktop!
      unison # Back those files up, son.
      magic-wormhole # Magically transfer stuff between your wormholes!
      oneshot # Basically `python -m http.server` that can deliver files to various devices.
      qbittorrent # Free version of uBittorrent.
      xfce.thunar # A graphical file manager.
      xfce.thunar-volman # A Thunar plugin on volume management for external devices.
      udiskie # An automounter for external devices with authentication.
    ];

    services = {
      # Enable Syncthing for them cross-device syncing.
      syncthing.enable = true;

      # Argh! Open t' gateweh t' th' high seas!
      transmission.enable = true;
    };

    # Clean 'yer home!
    my.env = {
      RECOLL_CONFDIR = "$XDG_DATA_HOME/recoll";
      UNISON = "$XDG_DATA_HOME/unison";
    };
  };
}
