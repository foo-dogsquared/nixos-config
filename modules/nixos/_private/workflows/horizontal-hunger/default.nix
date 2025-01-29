{ config, options, lib, pkgs, foodogsquaredLib, ... }:

let
  workflowId = "one.foodogsquared.HorizontalHunger";

  cfg = config.workflows.workflows.${workflowId};
  sessionConfig = config.programs.gnome-session.sessions.${workflowId};

  requiredPackages = with pkgs; [
    # The window manager. We only put this here since it has some commands that
    # are useful to be having.
    cfg.package

    # The application opener.
    junction
  ];

  workflowEnvironment = foodogsquaredLib.nixos.mkNixoslikeEnvironment config {
    name = "${workflowId}-env";
    paths = requiredPackages ++ cfg.extraApps;
  };
in {
  options.workflows.enable =
    lib.mkOption { type = with lib.types; listOf (enum [ workflowId ]); };

  options.workflows.workflows.${workflowId} = {
    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        Derivation containing {program}`niri` executable which is the preferred
        window manager for this workflow.
      '';
      default = pkgs.niri;
    };

    extraApps = lib.mkOption {
      type = with lib.types; listOf package;
      default = with pkgs; [ flowtime dialect blanket ];
      description = ''
        A list of extraneous applications to be included with the desktop
        session.
      '';
    };
  };

  config = lib.mkIf (lib.elem workflowId config.workflows.enable) {
    # Enable all of the core services.
    hardware.bluetooth.enable = true;
    programs.dconf.enable = true;
    programs.xwayland.enable = true;
    programs.gnupg.agent = {
      enable = lib.mkDefault true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
    security.polkit.enable = true;
    services.colord.enable = lib.mkDefault true;
    services.gnome.gnome-keyring.enable = lib.mkDefault true;
    services.power-profiles-daemon.enable = true;
    services.udisks2.enable = lib.mkDefault true;
    services.upower.enable = config.powerManagement.enable;
    services.libinput.enable = lib.mkDefault true;

    # Configuring the preferred network manager.
    networking.networkmanager.enable = true;

    # Configuring the XDG desktop components. Take note all of these are
    # required for the desktop widgets components to work since they rely on
    # them.
    xdg.mime.enable = true;
    xdg.icons.enable = true;

    # For now, the portal configuration doesn't work since Niri is now
    # hardcoded to set the apprioriate envs for portal component. It is
    # considered broken (or rather unused) for now.
    xdg.portal = lib.mkMerge [
      {
        enable = lib.mkDefault true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

        # The option value is only a coerced `lib.type.str` so ehhh...
        config.${workflowId}.default = [ "gtk" ]
          ++ lib.optionals (config.services.gnome.gnome-keyring.enable)
          [ "gnome" ];
      }

      (lib.mkIf config.services.gnome.gnome-keyring.enable {
        config.${workflowId} = {
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      })
    ];

    # Install of the programs.
    environment.systemPackages = requiredPackages ++ cfg.extraApps;

    # Configuring the actual desktop session.
    programs.gnome-session.sessions.${workflowId} = {
      fullName = "Horizontal Hunger";
      desktopNames = [ workflowId ];

      systemd.targetUnit = let
        requiredComponents = [ "window-manager" ];
        getId = lib.foldlAttrs (acc: _: v: acc ++ [ "${v.id}.target" ]) [ ];
      in {
        requires = getId (lib.filterAttrs (n: _: lib.elem n requiredComponents)
          sessionConfig.components);
        wants = getId (lib.attrsets.removeAttrs sessionConfig.components
          requiredComponents);
      };

      components = {
        window-manager = {
          script = "${
              lib.getExe' cfg.package "niri"
            } --config /tmp/shared/modules/nixos/_private/workflows/horizontal-hunger/config/niri/config";
          description = "Window manager";

          systemd.serviceUnit = {
            serviceConfig = {
              Type = "notify";
              NotifyAccess = "all";
              OOMScoreAdjust = -1000;
            };

            unitConfig = {
              OnFailure = [ "gnome-session-shutdown.target" ];
              OnFailureJobMode = "replace-irreversibly";
            };

            startLimitBurst = 5;
            startLimitIntervalSec = 10;
          };

          systemd.targetUnit = {
            partOf = [ "gnome-session-initialized.target" ];
            after = [ "gnome-session-initialized.target" ];
          };
        };

        desktop-widgets = {
          script = "${
              lib.getExe' pkgs.ags "ags"
            } --config /tmp/shared/modules/nixos/_private/workflows/horizontal-hunger/config/ags/config.js";
          description = "Desktop widgets";

          systemd.serviceUnit = {
            serviceConfig = {
              Type = "notify";
              NotifyAccess = "all";
              OOMScoreAdjust = -1000;
            };

            unitConfig = {
              OnFailure = [ "gnome-session-shutdown.target" ];
              OnFailureJobMode = "replace-irreversibly";
            };
          };

          systemd.targetUnit = {
            partOf = [ "gnome-session-initialized.target" ];
            after = [ "gnome-session-initialized.target" ];
          };
        };

        auth-agent = {
          script =
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          description = "Authentication agent";

          systemd.serviceUnit = {
            serviceConfig = {
              Type = "notify";
              NotifyAccess = "all";
              OOMScoreAdjust = -500;
            };
          };

          systemd.targetUnit = {
            partOf = [ "graphical-session.target" "gnome-session.target" ];
          };
        };
      };
    };
  };
}
