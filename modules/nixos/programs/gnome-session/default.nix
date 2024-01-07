{ config, lib, pkgs, utils, ... }@moduleArgs:

let
  cfg = config.programs.gnome-session;
  inherit (import ./submodules.nix moduleArgs) sessionType;
in
{
  options.programs.gnome-session = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gnome.gnome-session;
      defaultText = "pkgs.gnome.gnome-session";
      description = ''
        The package containing gnome-session binary and systemd units. This
        module will use the `gnome-session` executable for the generated
        session script.
      '';
    };

    sessions = lib.mkOption {
      type = with lib.types; attrsOf (submodule sessionType);
      description = ''
        A set of desktop sessions to be created with
        {manpage}`gnome-session(1)`. This gnome-session configuration generates
        both the `.desktop` file and systemd units to be able to support both
        the built-in and the systemd-managed GNOME session.

        Each of the attribute name will be used as the identifier of the
        desktop environment. While you can make identifiers in any way, it is
        encouraged to stick to a naming scheme. Here's two common ways to name
        a desktop environment.

        * Reverse DNS-like scheme (e.g., `com.example.MoseyBranch`).
        * Kebab-case (e.g., `mosey-branch`).
      '';
      default = { };
      example = lib.literalExpression ''
        {
          "gnome-minimal" = let
            sessionCfg = config.programs.gnome-session.sessions."gnome-minimal";
          in
          {
            fullName = "GNOME (minimal)";
            description = "Minimal GNOME session";
            display = [ "wayland" "xorg" ];
            extraArgs = [ "--systemd" ];

            requiredComponents =
              let
                gsdComponents =
                  builtins.map
                    (gsdc: "org.gnome.SettingsDaemon.''${gsdc}")
                    [
                      "A11ySettings"
                      "Color"
                      "Housekeeping"
                      "Power"
                      "Keyboard"
                      "Sound"
                      "Wacom"
                      "XSettings"
                    ];
              in
              gsdComponents ++ [ "org.gnome.Shell" ];

            targetUnit = {
              requires = [ "org.gnome.Shell.target" ];
              wants = builtins.map (c: "''${c}.target") (lib.lists.remove "org.gnome.Shell" sessionCfg.requiredComponents);
            };
          };

          "one.foodogsquared.SimpleWay" = {
            fullName = "Simple Way";
            description = "A desktop environment featuring Sway window manager.";
            display = [ "wayland" ];
            extraArgs = [ "--systemd" ];

            components = {
              # This unit is intended to start with gnome-session.
              window-manager = {
                script = '''
                  ''${lib.getExe' config.programs.sway.package "sway"} --config ''${./config/sway/config}
                ''';
                description = "An i3 clone for Wayland.";

                serviceUnit = {
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

                targetUnit = {
                  requisite = [ "gnome-session-initialized.target" ];
                  partOf = [ "gnome-session-initialized.target" ];
                  before = [ "gnome-session-initialized.target" ];
                };
              };

              desktop-widgets = {
                script = '''
                  ''${lib.getExe' pkgs.ags "ags"} --config ''${./config/ags/config.js}
                ''';
                description = "A desktop widget system using layer-shell protocol.";

                serviceUnit = {
                  serviceConfig = {
                    OOMScoreAdjust = -1000;
                  };

                  path = with pkgs; [ ags ];

                  startLimitBurst = 5;
                  startLimitIntervalSec = 15;
                };

                targetUnit = {
                  requisite = [ "gnome-session-initialized.target" ];
                  partOf = [ "gnome-session-initialized.target" ];
                  before = [ "gnome-session-initialized.target" ];
                };
              };

              auth-agent = {
                script = "''${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
                description = "Authentication agent";

                serviceUnit = {
                  startLimitBurst = 5;
                  startLimitIntervalSec = 15;
                };

                targetUnit = {
                  partOf = [
                    "gnome-session.target"
                    "graphical-session.target"
                  ];
                  requisite = [ "gnome-session.target" ];
                  after = [ "gnome-session.target" ];
                };
              };
            };
          };
        }
      '';
    };
  };

  config = lib.mkIf (cfg.sessions != { })
    (
      let
        sessionPackages = lib.mapAttrsToList
          (_: session:
            session.sessionPackage)
          cfg.sessions;
      in
      {
        # Install all of the desktop session files.
        services.xserver.displayManager.sessionPackages = sessionPackages;
        environment.systemPackages = [ cfg.package ] ++ sessionPackages;

        # Make sure it is searchable within gnome-session.
        environment.pathsToLink = [ "/share/gnome-session" ];

        # Import those systemd units from gnome-session as well.
        systemd.packages = [ cfg.package ] ++ sessionPackages;
      }
    );
}
