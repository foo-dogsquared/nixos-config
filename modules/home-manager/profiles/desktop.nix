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
        emulsion-palette # Manage your color palettes.
        inkscape # Illustration wannabe tool.
        gimp # Photo editing wannabe tool.
        krita # Digital art wannabe tool.

        imagemagick # Ah yes, everyman's image manipulation tool.
        gmic # Don't let the gimmicks fool you, it's a magical image framework.
      ];
    })

    (lib.mkIf cfg.audio.enable {
      home.packages = with pkgs; [
        musescore # The free composition tool.
        zrythm # The freer FL Studio (if you're sailing by the high seven seas).

        # !!! Be sure to install Wine for this one.
        yabridge # Building bridges to Windows and Linux audio tools.
        yabridgectl # The bridge controller.

        helvum # The Pipewire Patchbay.
        carla # The Carla Carla.
      ];

      # This is assuming you're using Pipewire, yes?
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
        thunderbird # Email checks.
      ];

      programs.sioyek = {
        enable = true;

        # All of my keybindings based from my Neovim workflow.
        bindings = {
          "move_up" = [ "k" "<up>" ];
          "move_down" = [ "j" "<down>" ];
          "move_left" = [ "h" "<left>" ];
          "move_right" = [ "l" "<right>" ];
          "next_page" = [ "<C-f>" "<S-<down>>" ];
          "previous_page" = [ "<C-b>" "<S-<up>>" ];
          "screen_down" = [ "<C-d>" "d" ];
          "screen_up" = [ "<C-u>" "u" ];
          "fit_to_page_width_smart" = "<C-S-f>";
          "copy" = "y";
          "goto_toc" = [ "t" "g<S-o>" ];
          "open_prev_doc" = [ "<S-o>" "fbb" ];
          "open_last_document" = [ "^" "<C-S-6>" ];
        };

        config = {
          "search_url_b" = "https://search.brave.com/search?q=";
          "shift_middle_click_engine" = "b";
          "ui_font" = "sans-serif";
          "font_size" = "24";
        };
      };
    })
  ]);
}
