# Enables all of my usual setup for desktop-oriented stuff.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.desktop;
in
{
  options.modules.desktop = {
    enable = lib.mkEnableOption "Enable installations of desktop apps.";
    graphics.enable = lib.mkEnableOption "Install graphics-related apps.";
    audio.enable = lib.mkEnableOption "Install audio-related apps.";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.graphics.enable {
      home.packages = with pkgs; [
        aseprite # Pixel art wannabe tool.
        blender # 3D modelling wannabe tool.
        inkscape # Illustration wannabe tool.
        gimp # Photo editing wannabe tool.
        krita # Digital art wannabe tool.

        imagemagick # Ah yes, everyman's image manipulation tool.
        gmic # Don't let the gimmicks fool you, it's a magical image framework.
      ];
    })

    (lib.mkIf cfg.audio.enable {
      home.packages = with pkgs; [
        ardour # The big boi in Linux music production with FOSS.
        musescore

        # Trying to
        yabridge
        yabridgectl
        helvum
      ];

      services.easyeffects.enable = true;
    })
  ]);
}
