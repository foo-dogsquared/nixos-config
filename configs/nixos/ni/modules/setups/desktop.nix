{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.desktop;

  hasAnyWorkflowEnabled = workflows:
    lib.lists.any (workflow: lib.elem workflow config.workflows.enable)
    workflows;
in {
  options.hosts.ni.setups.desktop.enable =
    lib.mkEnableOption "desktop environment setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Bring all of the desktop goodies.
      suites.desktop = {
        enable = true;
        audio.enable = true;
        windows-compatibility.enable = true;
        cleanup.enable = true;
      };

      # Apparently the Emacs of 3D artists.
      programs.blender = {
        enable = true;
        package = pkgs.blender-foodogsquared;
      };

      # Make it in multiple languages. Take note the input method engine is set
      # up by the workflow module of choice...
      suites.i18n.enable = true;

      # ...which is by the way is this one.
      workflows.enable = [ "one.foodogsquared.AHappyGNOME" ];
    }

    (lib.mkIf (hasAnyWorkflowEnabled [ "a-happy-gnome" "knome" ]) {
      hosts.ni.networking.setup = "networkmanager";
      suites.i18n.setup = "ibus";
    })
  ]);
}
