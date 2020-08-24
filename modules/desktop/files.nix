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
      exiftool              # A file metadata reader/writer/manager/helicopter.
      (recoll.override {
        withGui = false;
      })                    # Bring the search engine to the desktop!
      unison
      magic-wormhole        # Magically transfer stuff between your wormholes!
      transmission          # One of the components for sailing the high seas.
      syncthing             # A peer-to-peer synchro summoning.
      xfce.thunar           # A graphical file manager.
      xfce.thunar-volman    # A Thunar plugin on volume management for external devices.
      udiskie               # An automounter for external devices with authentication.
    ];

    # Clean 'yer home!
    my.env = {
      RECOLL_CONFDIR = "$XDG_DATA_HOME/recoll";
      UNISON = "$XDG_DATA_HOME/unison";
    };
  };
}
