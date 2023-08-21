{ config, options, lib, pkgs, ... }@attrs:

# TODO: Create Meson installation package for custom desktop environment
# session files and whatnot. I want to try out Meson and this is a perfect
# excuse.
let
  cfg = config.workflows.workflows.mosey-branch;
  workflowName = "mosey-branch";

  # A reverse DNS prefix similarly used to GNOME services.
  prefix = "one.foodogsquared.MoseyBranch.";

  createServiceScript = { runtimeInputs ? [], text, name }:
    let
      runtimeInputs' = runtimeInputs ++ [ pkgs.dbus ];
      text' = ''
        DESKTOP_AUTOSTART_ID="''${DESKTOP_AUTOSTART_ID:-}"
        echo "$DESKTOP_AUTOSTART_ID"
        test -n "$DESKTOP_AUTOSTART_ID" && {
          dbus-send --print-reply --session \
            --dest=org.gnome.SessionManager "/org/gnome/SessionManager" \
            org.gnome.SessionManager.RegisterClient \
            "string:${workflowName}" "string:$DESKTOP_AUTOSTART_ID"
        }

        ${text}
      '';
      script = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = runtimeInputs';
        text = text';
      };
    in "${script}/bin/${name}";

  customDesktopSession = pkgs.callPackage ./config/desktop-session {
    inherit prefix;
    serviceScript = createServiceScript {
      name = "${workflowName}-service-script";
      runtimeInputs = with pkgs; [ hyprland ];
      text = ''
        Hyprland --config ${./config/hyprland/hyprland.conf}

        test -n "$DESKTOP_AUTOSTART_ID" && {
          dbus-send --print-reply --session \
            --dest=org.gnome.SessionManager "/org/gnome/SessionManager" \
            org.gnome.SessionManager.Logout "uint32:1"
        }
      '';
    };
    agsScript = createServiceScript {
      name = "${workflowName}-widgets";
      runtimeInputs = with pkgs; [ ags ];
      text = "ags";
    };
    polkitScript = createServiceScript {
      name = "${workflowName}-authentication-agent";
      text = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    };
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

    debug = lib.mkEnableOption "gnome-session debug messages";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = cfg.extraApps ++ requiredPackages;

      # Install all of the required systemd units.
      systemd.packages = with pkgs.gnome; [
        customDesktopSession
        gnome-session
      ];

      # We'll have to include them for gnome-session to recognize it in NixOS
      # systems.
      environment.pathsToLink = [ "/share/gnome-session" ];

      environment.sessionVariables.GNOME_SESSION_DEBUG = lib.mkIf cfg.debug "1";

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
