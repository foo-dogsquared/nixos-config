{ config, options, lib, pkgs, ... }@attrs:

# TODO: Create Meson installation package for custom desktop environment
# session files and whatnot. I want to try out Meson and this is a perfect
# excuse.
let
  cfg = config.workflows.workflows.mosey-branch;
  workflowName = "mosey-branch";

  # A reverse DNS prefix similarly used to GNOME services.
  prefix = "one.foodogsquared.MoseyBranch.";

  customDesktopSession = pkgs.callPackage ./config/desktop-session {
    inherit prefix;
    serviceScript = pkgs.writeShellScript "${workflowName}-service-script" ''
      ${pkgs.hyprland}/bin/Hyprland --config ${./config/hyprland/hyprland.conf}
    '';
    sessionScript = pkgs.writeShellScript "${workflowName}-hyprland-custom-start" ''
      ${pkgs.gnome.gnome-session}/bin/gnome-session --session=${workflowName}
    '';
    agsScript = "${pkgs.ags}/bin/ags";
    polkitScript = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    ibusScript = pkgs.writeShellScript "${workflowName}-ibus-script" "${pkgs.ibus}/bin/ibus start";
  };

  requiredPackages = with pkgs; [
    # The star of this show: the window manager (or Wayland compositor if you
    # want to be a hair-pulling semantic bastard).
    hyprland

    # Setting up the widget system that will be used for notifications,
    # bar and its widgets, and custom menus.
    gjs
    ags
    gtk4-layer-shell

    # Install with the custom desktop session files.
    customDesktopSession

    # Optional dependencies that are required in this workflow module.
    socat
    qt5.qtwayland
    qt6.qtwayland

    # The authentication agent.
    polkit_gnome

    # The themes.
    hicolor-icon-theme

    # The chosen terminal emulator.
    wezterm
  ];
in
{
  options.workflows.workflows.mosey-branch = {
    enable = lib.mkEnableOption "${workflowName}, foodogsquared's Hyprland-based desktop environment";

    extraApps = lib.mkOption {
      description = ''
        Extra applications to be installed alongside the desktop environment.
      '';
      internal = true;
      type = with lib.types; listOf package;
      default = with pkgs; [
        amberol # Simplest music player.
        gradience # Gradually theme your shell with cadence.
        blanket # Blanket yourself in ambient sounds.
        eyedropper # Some nice eyedropper tool.
        shortwave # Your internet radio.
        flowtime # A nice timer for overworked students.
        gnome-solanum # Cute little matador timer.
        gnome-frog # Read them QR codes where it sends you to that one video everytime.
        gnome.gnome-boxes # Virtual machines, son.
        tangram # Make yourself a professional social media manager.
      ];
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = cfg.extraApps ++ requiredPackages;
      systemd.packages = [ customDesktopSession ];

      # Our preferred display manager.
      services.xserver = {
        enable = true;
        displayManager = {
          gdm.enable = lib.mkDefault true;
          sessionPackages = [ customDesktopSession ];
        };
        updateDbusEnvironment = true;
      };

      # Setting up some hardware settings.
      hardware.opengl.enable = true;
      hardware.bluetooth.enable = true;
      services.udisks2.enable = true;
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      services.colord.enable = true;
      services.system-config-printer.enable = config.services.printing.enable;

      # Setting up some more core services.
      security.polkit.enable = true;
      services.accounts-daemon.enable = true;
      services.dleyna-renderer.enable = true;
      services.dleyna-server.enable = true;
      programs.dconf.enable = true;
      programs.xwayland.enable = true;

      fonts.enableDefaultPackages = true;

      # The phone sync component which is handy.
      programs.kdeconnect = {
        enable = true;
        package = pkgs.valent;
      };

      # Harmonious themes. Since we're making this very similar to GNOME
      # appearance-wise, layout-wise, and setup-wise, we may as well make it
      # similar.
      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita";
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
        ];
      };
    }

    # Setting up my project-specific profiles. This is only to be applied for
    # my setup. If you're not foodogsquared and you're using my project as one
    # of the flake input, this shouldn't be applied nor be used in the first
    # place.
    (lib.mkIf (attrs ? _isfoodogsquaredcustom && attrs._isfoodogsquaredcustom) {
      profiles.i18n = {
        enable = true;
        fcitx5.enable = true;
      };
    })
  ]);
}
