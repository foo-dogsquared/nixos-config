{ config, options, lib, pkgs, ... }:

let
  cfg = config.workflows.workflows.knome;
in
{
  options.workflows.workflows.knome.enable = lib.mkEnableOption "KNOME, an attempt to bring as much GNOME to KDE Plasma";

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5 = {
        enable = true;

        # CAUTION: These are internal options so expect sudden changes.
        kwinrc = {
          Compositing.OpenGLIsUnsafe = false;
          Effect-PresentWindows = {
            BorderActivate = 7;
            BorderActivateAll = 9;
          };
          ModifierOnlyShortcuts.Meta = "org.kde.krunner,/App,,toggleDisplay";
          NightColor.Active = true;
          Plugins.overviewEnabled = true;

          # The title bar decorations.
          "org.kde.kdecoration2" = {
            ButtonsOnLeft = "N";
            ButtonsOnRight = "X";
            ShowToolTips = false;
          };

          # Set touch edges to nothing as my preferences.
          # I let my keyboard do the work as much as possible.
          TouchEdges = {
            Bottom = "none";
            Left = "none";
            Right = "none";
            Top = "none";
          };

          # Filtering windows by the current activity only and nothing else.
          # The default also includes through the same desktop which severely limits my task switching.
          TabBox = {
            ApplicationsMode = 1;
            DesktopMode = 0;
          };
        };

        kdeglobals = {
          KDE = {
            AnimationDuration = 0.5;
            LookAndFeelPackage = "org.kde.breezedark.desktop";
          };
        };
      };
    };

    # Put all of the Plasma dotfiles in certain locations.
    environment.etc = {
      "xdg/baloofilerc".source = ./config/kde/baloofilerc;
      "xdg/kglobalshortcutsrc".source = ./config/kde/kglobalshortcutsrc;
      "xdg/khotkeysrc".source = ./config/kde/khotkeysrc;
      "xdg/klaunchrc".source = ./config/kde/klaunchrc;
      "xdg/krunnerrc".source = ./config/kde/krunnerrc;
      "xdg/plasma-org.kde.plasma.desktop-appletsrc".source = ./config/kde/plasma-org.kde.plasma.desktop-appletsrc;
      "xdg/plasmanotifyrc".source = ./config/kde/plasmanotifyrc;
      "xdg/plasmarc".source = ./config/kde/plasmarc;
    };

    # Install additional packages.
    environment.systemPackages = with pkgs; [
      kitty # The preferred terminal emulator.
    ] ++ (with pkgs.plasma5Packages; [
      bismuth # Tiling inside Plasma?

      # Powering up Krunner.
      krunner-symbols
      krunner-ssh
    ]);

    programs.kdeconnect.enable = true;
  };
}
