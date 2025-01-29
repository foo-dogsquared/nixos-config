{ config, lib, pkgs, utils, ... }:

let
  cfg = config.programs.sessiond;

  sessionPackages = lib.mapAttrsToList (_: session:
    let
      displaySession = ''
        [Desktop Entry]
        Name=${session.fullName}
        Comment=${session.description}
        Exec="@out@/libexec/${session.name}-session"
        Type=Application
        DesktopNames=${lib.concatStringsSep ";" session.desktopNames};
      '';

      sessionScript = ''
        #!${pkgs.runtimeShell}

        ${lib.getExe' cfg.package "sessionctl"} run "${session.name}.target"
      '';
    in pkgs.runCommandLocal "${session.name}-desktop-session-files" {
      inherit displaySession sessionScript;
      passAsFile = [ "displaySession" "sessionScript" ];
      passthru.providedSessions = [ session.name ];
    } ''
      SESSION_SCRIPT="$out/libexec/${session.name}-session"
      install -Dm0755 "$sessionScriptPath" "$SESSION_SCRIPT"
      substituteAllInPlace "$SESSION_SCRIPT"

      DISPLAY_SESSION_FILE="$out/share/xsessions/${session.name}.desktop"
      install -Dm0644 "$displaySessionPath" "$DISPLAY_SESSION_FILE"
      substituteAllInPlace "$DISPLAY_SESSION_FILE"
    '') cfg.sessions;

  sessionSystemdUnits = lib.concatMapAttrs (name: session:
    let
      inherit (utils.systemdUtils.lib)
        pathToUnit serviceToUnit targetToUnit timerToUnit socketToUnit;

      mkSystemdUnits = name: component:
        {
          "${component.id}.service" = serviceToUnit component.serviceUnit;
          "${component.id}.target" = targetToUnit component.targetUnit;
        } // lib.optionalAttrs (component.socketUnit != null) {
          "${component.id}.socket" = socketToUnit component.socketUnit;
        } // lib.optionalAttrs (component.timerUnit != null) {
          "${component.id}.timer" = timerToUnit component.timerUnit;
        } // lib.optionalAttrs (component.pathUnit != null) {
          "${component.id}.path" = pathToUnit component.pathUnit;
        };

      sessionComponents = lib.concatMapAttrs mkSystemdUnits session.components;
    in sessionComponents // {
      "${session.name}.service" = serviceToUnit session.serviceUnit;
      "${session.name}.target" = targetToUnit session.targetUnit;
    }) cfg.sessions;
in {
  options.programs.sessiond = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sessiond;
      defaultText = "pkgs.sessiond";
      description = ''
        The package containing sessiond executable and systemd units. This
        module will use the `sessiond` executable for the generated session
        script.
      '';
    };

    sessions = lib.mkOption {
      type = with lib.types;
        attrsOf (submoduleWith {
          specialArgs = {
            inherit utils pkgs;
            sessiondPkg = cfg.package;
          };
          modules = [ ./submodules/session-type.nix ];
        });
      example = lib.literalExpression ''
        {
          "com.example.Beepeedobolyuessemm" = {
            description = "Simple desktop environment featuring bspwm";
            desktopNames = [ "Beepeedobolyuessemm" ];

            settings = {
              Idle = {
                Inputs = [ "motion" "button-press" "key-press" ];
                IdleSec = 120;
              };

              Lock = {
                OnIdle = true;
                OnSleep = true;
                MuteAudio = true;
              };

              Hook = [
                {
                  Trigger = "Idle";
                  ExecStart = "''${lib.getExe' pkgs.betterlockscreen "betterlockscreen"} --off 240";
                }
              ];
            };

            components = {
              window-manager = {
                description = "Window manager";

                serviceUnit = {
                  # This is required for sessiond to recognize which unit is the
                  # window manager.
                  aliases = [ "window-manager.service" ];

                  script = '''
                    ''${lib.getExe' pkgs.bspwm "bspwm"} -c ''${./config/bspwm/bspwmrc}
                  ''';

                  serviceConfig = {
                    ExecStopPost = "''${lib.getExe' sessiondPkg "sessionctl"} stop";
                    OOMScoreAdjust = -1000;
                  };
                };

                targetUnit = {
                  requires = [ "sessiond-session.target" ];
                  partOf = [ "sessiond-session.target" ];
                  wantedBy = [ "sessiond-session.target" ];
                };
              };

              hotkey-daemon = {
                description = "Hotkey daemon";

                serviceUnit = {
                  documentation = [ "man:sxhkd(1)" ];

                  script = '''
                    ''${lib.getExe' pkgs.sxhkd "sxhkd"} -c ''${./config/sxhkd/bindings}
                  ''';

                  serviceConfig = {
                    ExecReload = "''${lib.getExe' pkgs.coreutils "kill"} -SIGUSR1 $MAINPID";
                    ExecStopPost = "''${lib.getExe' sessiondPkg "sessionctl"} stop";
                    OOMScoreAdjust = -1000;
                  };
                };

                targetUnit = {
                  after = [ "display-manager.service" ];
                  partOf = [ "sessiond-session.target" ];
                };
              };
            };
          };
        }
      '';
      description = ''
        A set of desktop sessions to be configured with sessiond. Each of the
        attribute name will be used as the identifier of the desktop
        environment.

        ::: {.tip}
        While you can make identifiers in any way, it is encouraged to stick to
        a naming scheme. The recommended method is a reverse DNS-like scheme
        preferably with a domain name you own (e.g.,
        `com.example.MoseyBranch`).
        :::
      '';
      default = { };
    };
  };

  config = lib.mkIf (cfg.sessions != { }) {
    environment.systemPackages = [ cfg.package ];

    # Install all of the desktop session files.
    services.displayManager.sessionPackages = sessionPackages;

    # Import those systemd units from sessiond as well.
    systemd.packages = [ cfg.package ];
    systemd.user.units = sessionSystemdUnits;

    # We're disabling the upstream sessiond service since we have our own set
    # of sessiond sessions here.
    systemd.user.services.sessiond.enable = lib.mkForce false;
  };
}
