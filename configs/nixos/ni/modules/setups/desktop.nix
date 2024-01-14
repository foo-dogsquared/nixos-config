{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.desktop;

  hasAnyWorkflowEnabled = workflows:
    lib.lists.any (workflow: config.workflows.workflows.${workflow}.enable) workflows;
in
{
  options.hosts.ni.setups.desktop.enable =
    lib.mkEnableOption "desktop environment setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
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

      # Make it in multiple languages. Take note the input method engine is set
      # up by the workflow module of choice...
      profiles.i18n.enable = true;

      # ...which is by the way is this one.
      workflows.workflows.a-happy-gnome.enable = true;
    }

    (lib.mkIf (hasAnyWorkflowEnabled [ "a-happy-gnome" "knome" "mosey-branch" ]) {
      hosts.ni.networking.setup = "networkmanager";
      profiles.i18n.setup = "ibus";
    })
  ]);
}
