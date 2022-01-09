# Enables all of my usual setup for desktop-oriented stuff.
{ config, options, lib, pkgs, ... }:

let cfg = config.profiles.desktop;
in {
  options.profiles.desktop = {
    enable = lib.mkEnableOption "installations of desktop apps";
    graphics.enable =
      lib.mkEnableOption "installations of graphics-related apps";
    audio.enable = lib.mkEnableOption "installations of audio-related apps";
    multimedia.enable =
      lib.mkEnableOption "installations for opening multimedia files";
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
        ardour
        musescore

        # Trying to
        yabridge
        yabridgectl
        helvum
      ];

      services.easyeffects.enable = true;
      services.fluidsynth = {
        enable = true;
        soundService = "pipewire-pulse";
      };
    })

    (lib.mkIf cfg.multimedia.enable {
      home.packages = with pkgs; [
        mpv # The modern VLC.
        brave # The only web browser that gives me money.
        foliate # The prettier PDF viewer.
        sioyek # The researcher's PDF viewer.
        thunderbird # Email checks.
      ];
    })
  ]);
}
