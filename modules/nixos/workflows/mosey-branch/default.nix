{ config, options, lib, pkgs, ... }@attrs:

let
  cfg = config.workflows.workflows.mosey-branch;
  workflowName = "mosey-branch";

  # This is used in a similar manner for GNOME desktop applications and its
  # services.
  prefix = "one.foodogsquared.${workflowName}.";

  hyprlandCustomGnomeSession = pkgs.substituteAll {
    src = ./config/gnome-session/hyprland.session;
    name = "${workflowName}.session";
    dir = "share/gnome-session";
    requiredComponents =
      lib.concatMapString (component: "${prefix}${component};") ([
        "ags"
        "polkit"
      ]
      ++ lib.optional (config.i18n.inputMethod == "fcitx5") "fcitx5"
      ++ lib.optional (config.i18n.inputMethod == "ibus") "ibus");
  };

  hyprlandStartScript = pkgs.writeShellScript "${workflowName}-hyprland-custom-start" ''
    ${pkgs.gnome.gnome-session}/bin/gnome-session --session=${workflowName}
  '';

  hyprlandSessionPackage =
    (pkgs.substituteAll {
      src = ./config/wayland-sessions/hyprland.desktop;
      name = "${workflowName}.desktop";
      dir = "share/wayland-sessions";
      script = hyprlandStartScript;
    }).overrideAttrs {
      passthru.providedSessions = [ workflowName ];
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

    # Install with the custom session.
    hyprlandCustomGnomeSession

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

  createPrefixedServices = name: value:
    lib.nameValuePair "${prefix}${name}" (value // {
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "gnome-session.target" ];
    });
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

      # Our preferred display manager.
      services.xserver = {
        enable = true;
        displayManager = {
          gdm.enable = lib.mkDefault true;
          sessionPackages = [ hyprlandSessionPackage ];
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

    # These are all intended to be started with gnome-session.
    # Much of the templates used are from Phosh systemd templates at
    # https://gitlab.gnome.org/World/Phosh/phosh/-/blob/main/data/systemd.
    # Big thanks to them! :)
    {
      systemd.user.targets."${prefix}" = {
        description = "${workflowName} Hyprland shell";
        documentation = [ "man:systemd.special(7)" ];
        unitConfig.DefaultDependencies = "no";
        requisite = [ "gnome-session-initialized.target" ];
        partOf = [ "gnome-session-initialized.target" ];
        before = [ "gnome-session-initialized.target" ];

        wants = [ "${prefix}.service" ];
        after = [ "${prefix}.service" ];
      };

      systemd.user.services = lib.mapAttrs' createPrefixedServices {
        ags = {
          description = "Widget system layer for the desktop";
          script = "${pkgs.ags}/bin/ags";
        };

        polkit = {
          description = "Authentication agent for the desktop session";
          script = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        };

        fcitx5 = lib.mkIf (config.i18n.inputMethod.enabled == "fcitx5") {
          description = "Input method engine for the desktop session";
          script = "${config.i18n.inputMethod.package}/bin/fcitx5";
        };

        ibus = lib.mkIf (config.i18n.inputMethod.enabled == "ibus") {
          description = "Input method engine for the desktop session";
          script = "${config.i18n.inputMethod.package}/bin/ibus start";
        };
      } // {
        "${prefix}" = {
          description = "${workflowName}, a custom desktop session with Hyprland";
          documentation = [ "https://wiki.hyprland.org" ];
          after = [ "gnome-manager-manager.target" ];
          requisite = [ "gnome-session-initialized.target" ];
          partOf = [ "gnome-session-initialized.target" ];

          unitConfig = {
            OnFailure = "gnome-session-shutdown.target";
            OnFailureJobMode = "replace-irreversibly";
            CollectMode = "inactive-or-failed";
            RefuseManualStart = true;
            RefuseManualStop = true;
          };

          script = "${pkgs.hyprland}/bin/Hyprland --config ${./config/hyprland/hyprland.conf}";
        };
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
