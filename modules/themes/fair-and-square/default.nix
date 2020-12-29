{ config, options, lib, pkgs, ... }:

with lib; {
  options.modules.themes."fair-and-square" = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.themes."fair-and-square".enable {
    services = {
      # Enable picom compositor.
      picom = {
        enable = true;
        fade = false;
        shadow = false;
      };

      # Enable certain Xorg-related services.
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

    my.env.TERMINAL = "alacritty";

    my.home = {
      # Enable GTK configuration.
      gtk.enable = true;

      # Set the wallpaper.
      home.file.".background-image".source = ./config/wallpaper;

      # Enable QT configuration and set it to the same GTK config.
      qt.enable = true;
      qt.platformTheme = "gtk";

      # Install all of the configurations in the XDG config home.
      xdg.configFile = mkMerge [
        (let
          recursiveXdgConfig = name: {
            source = ./config + "/${name}";
            recursive = true;
          };
        in {
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

        # Applying the theme for GTK.
        ({
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
          '';

          "gtk-2.0/gtkrc".text = ''
            gtk-theme-name="Arc"
            gtk-icon-theme-name="Arc"
            gtk-font-name="Sans 10"
            gtk-cursor-theme-name="Adwaita"
          '';
        })
      ];

      # Set the cursor theme.
      xdg.dataFile = {
        "icons/default/index.theme".text = ''
          [icon theme]
          Inherits=Adwaita
        '';
      };
    };

    my.packages = with pkgs; [
      alacritty # Muh GPU-accelerated terminal emulator.
      dunst # Add more annoying pop-ups on your screen!
      feh # Meh, it's a image viewer that can set desktop background, what gives?
      gnome3.adwaita-icon-theme
      libnotify # Library for yer notifications.
      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      }) # Add some bars to your magnum opus.
      rofi # A ricer's best friend (one of them at least).

      # The Arc theme
      arc-icon-theme
      arc-theme
    ];

    fonts.fonts = with pkgs; [ iosevka nerdfonts font-awesome-ttf ];
  };
}
