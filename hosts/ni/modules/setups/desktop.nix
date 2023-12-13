{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.desktop;
in
{
  options.hosts.ni.setups.desktop.enable =
    lib.mkEnableOption "desktop environment setup";

  config = lib.mkIf cfg.enable {
    # Bring all of the desktop goodies.
    profiles.desktop = {
      enable = true;
      audio.enable = true;
      fonts.enable = true;
      hardware.enable = true;
      cleanup.enable = true;
      wine.enable = true;
    };

    # Apparently the Emacs of 3D artists.
    programs.blender = {
      enable = true;
      package = pkgs.blender-foodogsquared;
      addons = with pkgs; [
        blender-blendergis
        blender-machin3tools
      ];
    };

    # Make it in multiple languages. Take note this is meant to be set up by
    # the workflow module of choice...
    profiles.i18n.enable = true;

    # ...which is by the way is this one.
    workflows.workflows.a-happy-gnome.enable = true;

    # Backup for the almighty archive, pls.
    tasks.backup-archive.enable = true;
  };
}
