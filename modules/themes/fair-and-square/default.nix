{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.themes."fair-and-square" = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.themes."fair-and-square".enable {
    # Pass the metadata of the theme.
    modules.themes = {
      name = "Fair and square";
      version = "0.1.0";
      path = ./.;
    };

    # Enable picom compositor.
    services = {
      picom = {
        enable = true;
        fade = false;
        shadow = false;
      };

      xserver = {
        displayManager = {
          lightdm.enable = true;
          defaultSession = "none+bspwm";
        };
        enable = true;
        libinput.enable = true;
        windowManager.bspwm.enable = true;
      };
    };

    # Enable QT configuration to style with the GTK theme.
    qt5 = {
      style = "gtk2";
      platformTheme = "gtk2";
    };


    my.env.TERMINAL = "alacritty";

    my.home = {
      # Install all of the configurations in the XDG config home.
      xdg.configFile = mkMerge [
        (let recursiveXdgConfig = name: {
          source = ./config + "/${name}";
          recursive = true;
        }; in {
          "alacritty" = recursiveXdgConfig "alacritty";
          "bspwm" = recursiveXdgConfig "bspwm";
          "dunst" = recursiveXdgConfig "dunst";
          "polybar" = recursiveXdgConfig "polybar";
          "rofi" = recursiveXdgConfig "rofi";

          "sxhkd" = {
            source = <config/sxhkd>;
            recursive = true;
          };
        })

        {
          "gtk-3.0/settings.ini".text = ''
            [Settings]
            gtk-theme-name=Arc
            gtk-icon-theme-name=Arc
            gtk-fallback-icon-theme=gnome
            gtk-application-prefer-dark-theme=true
            gtk-cursor-theme-name=Adwaita
            gtk-xft-hinting=1
            gtk-xft-hintstyle=hintfull
            gtk-xft-rgba=none
            gtk-font-name=Sans 10
          '';
        }
      ];

      # Except for the GTK2 config which still needs to be in `$HOME/.gtkrc-2.0`.
      home.file = {
        ".gtkrc-2.0".text = ''
          gtk-theme-name="Arc"
          gtk-icon-theme-name="Arc"
          gtk-font-name="Sans 10"
          gtk-cursor-theme-name="Adwaita"
        '';
      };
    };

    my.packages = with pkgs; [
      alacritty         # Muh GPU-accelerated terminal emulator.
      dunst             # Add more annoying pop-ups on your screen!
      feh               # Meh, it's a image viewer that can set desktop background, what gives?
      gnome3.adwaita-icon-theme
      libnotify         # Library for yer notifications.
      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      })                # Add some bars to your magnum opus.
      rofi              # A ricer's best friend (one of them at least).

      # The Arc theme
      arc-icon-theme
      arc-theme
    ];

    fonts.fonts = with pkgs; [
      iosevka
      font-awesome-ttf
    ];
  };
}
