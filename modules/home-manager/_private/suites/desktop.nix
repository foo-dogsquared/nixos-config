# Enables all of my usual setup for desktop-oriented stuff.
{ config, lib, pkgs, ... }@attrs:

let
  cfg = config.suites.desktop;
in
{
  options.suites.desktop = {
    enable = lib.mkEnableOption "installations of desktop apps";
    graphics.enable =
      lib.mkEnableOption "installations of graphics-related apps";
    audio = {
      enable = lib.mkEnableOption "installations of audio-related apps";
      pipewire.enable = lib.mkOption {
        type = lib.types.bool;
        default = attrs.nixosConfig.services.pipewire.enable or false;
        description = ''
          Enable whether to install Pipewire-related applications.

          This module is implicitly enabled if used as part of the NixOS
          configuration and has Pipewire service enabled.
        '';
      };
    };
    video.enable = lib.mkEnableOption "installations of video-related apps";
    documents.enable =
      lib.mkEnableOption "installations for document-related apps";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.graphics.enable {
      home.packages = with pkgs; [
        aseprite # Pixel art wannabe tool.
        emulsion-palette # Manage your color palettes.
        eyedropper # Gotta keep your monitor moist.
        inkscape-with-extensions # Illustration wannabe tool.
        gimp-with-plugins # Photo editing wannabe tool.
        krita # Digital art wannabe tool.
        pureref # Pure references.

        ffmpeg-full # Ah yes, everyman's multimedia swiss army knife.
        imagemagick # Ah yes, everyman's image manipulation tool.
        gmic # Don't let the gimmicks fool you, it's a magical image framework.
      ]
      ++ (
        let
          hasBlenderNixOSModule = attrs.nixosConfig.programs.blender.enable or false;
        in
        lib.optional (!hasBlenderNixOSModule) pkgs.blender
      );
    })

    (lib.mkIf cfg.audio.enable {
      home.packages = with pkgs; [
        audacity # EGADS!!!
        musescore # You won't find muses to score, only music: a common misconception.
        zrythm # The freer FL Studio (if you're sailing by the high seven seas).
        supercollider-with-plugins # Not to be confused with the other Super Collider.
        sonic-pi # The only pie you'll get from this is worms which I heard is addicting.
        ffmpeg-full # Ah yes, everyman's multimedia swiss army knife.
      ]
      ++ (
        let
          hasDesktopSuiteEnabled = attrs.nixosConfig.suites.desktop.enable or false;
        in
        lib.optionals hasDesktopSuiteEnabled (with pkgs; [
          yabridge # Building bridges to Windows and Linux audio tools.
          yabridgectl # The bridge controller.
        ])
      );
    })

    (lib.mkIf cfg.audio.pipewire.enable {
      # This is assuming you're using Pipewire, yes?
      services.easyeffects.enable = true;
      services.fluidsynth = {
        enable = true;
        soundService =
          let
            hasNixOSPipewirePulseEnabled = attrs.nixosConfig.services.pipewire.enable or false;
          in
          lib.mkIf hasNixOSPipewirePulseEnabled "pipewire-pulse";
      };

      home.packages = with pkgs; [
        helvum # The Pipewire Patchbay.
        carla # The Carla Carla.
      ];
    })

    (lib.mkIf cfg.video.enable {
      home.packages = with pkgs; [
        ffmpeg-full # Ah yes, everyman's multimedia swiss army knife.
        kdenlive # YOU! Edit this video and live in a den, 'k?
        gnome-video-effects # A bunch of stock video effects.
      ];

      # The one-stop shop for your broadcasting and recording needs. Not to be
      # confused with the build service.
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          droidcam-obs
          obs-multi-rtmp
          obs-gstreamer
          obs-pipewire-audio-capture
          obs-source-switcher
          obs-vkcapture
          wlrobs
        ];
      };

      # The modern VLC if you have little sense of design.
      programs.mpv = {
        enable = true;
        config = {
          ytdl-format = "(webm,mkv,mp4)[height<=?1280]";
          ytdl-raw-options-append =
            let
              options = {
                yes-playlist = "";
              };
              options' = lib.mapAttrsToList (n: v: "${n}=${v}") options;
            in
            lib.concatStringsSep "," options';
          ordered-chapters = true;
          ab-loop-count = "inf";
          chapter-seek-threshold = 15.0;
          osc = false;
          sub-auto = "fuzzy";
          hwdec = "auto";
        };

        bindings = {
          "Ctrl+s" = "playlist-shuffle";
          "Alt+h" = "seek -5";
          "Alt+l" = "seek 5";
          "Alt+H" = "add chapter -1";
          "Alt+L" = "add chapter 1";

          "S" = "screenshot each-frame";

          "!" = "show-text \${playlist}";
          "@" = "show-text \${track-list}";
          "SHARP" = "show-text \${chapter-list}";

          # Ehhh, they're more getting in the way than just existing...
          "f" = "ignore";
          "T" = "ignore";
          "Alt+s" = "ignore";
        };

        profiles = {
          cjk = rec {
            profile-desc = "CJK prioritization";
            vlang = "zho,zh,kor,ko,jpn,ja,eng,en";
            alang = vlang;
            slang = with lib; concatStringsSep "," (reverseList (splitString "," vlang));
          };

          "extension.gif" = {
            osc = false;
            loop-file = "inf";
          };
        };

        scripts = with pkgs.mpvScripts; [
          mpris
          mpvacious
          mpv-playlistmanager
          thumbnail
          quality-menu
        ];
      };

      xdg.mimeApps.defaultApplications = {
        "audio/*" = [ "mpv.desktop" ];
        "video/*" = [ "mpv.desktop" ];
      };
    })

    (lib.mkIf cfg.documents.enable {
      home.packages = with pkgs; [
        dino # Some modern chat client featuring a dinosaur mascot for what could be considered a dinosaur.
        foliate # The prettier PDF viewer (if you're OK with a mixed bag of GTK3+GTK4 apps).
        languagetool # You're personal assistant for proper grammar,
        vale # Elevate your fanfics to a frivolously higher caliber!
      ];

      xdg.mimeApps.defaultApplications = {
        "application/pdf" = [
          "sioyek.desktop"
          "com.github.johnfactotum.Foliate.desktop"
        ];
      };

      # Some PDF viewer with a penchant for research.
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
