# This module supports both the built-in and systemd-managed desktop sessions
# for simplicity's sake and it is up to the user to configure one or the other
# (or both but in practice, the user will make use only one of them at a time
# so it's pointless). It also requires a lot of boilerplate which explains its
# size.
{ config, lib, pkgs, utils, ... }:

let
  cfg = config.programs.gnome-session;

  # The gnome-session config files uses one from GLib. See the following link
  # at <https://docs.gtk.org/glib/struct.KeyFile.html> for details about the
  # keyfile formatting and possibly the Desktop Entry specification at
  # <https://freedesktop.org/wiki/Specifications/desktop-entry-spec>.
  glibKeyfileFormat = {
    type = with lib.types;
      let
        valueType = oneOf [
          bool
          float
          int
          str
          (listOf valueType)
        ] // {
          description = "GLib keyfile atom (bool, int, float, string, or a list of the previous atoms)";
        };
      in
        attrsOf (attrsOf valueType);

    generate = name: value:
      pkgs.callPackage ({ writeText }:
        writeText name (lib.generators.toDconfINI value));
  };

  # The bulk of the work. Pretty much the main purpose of this module.
  sessionPackages = lib.mapAttrsToList
    (_: session:
      let
        gnomeSession = glibKeyfileFormat.generate "session-${session.name}" session.settings;

        # For now, we set this as a static template since there's not much
        # things to configure especially for a desktop session anyways.
        displaySession = ''
          [Desktop Entry]
          Name=${session.fullName}
          Comment=${session.description}
          Exec="@out@/libexec/${session.name}-session"
          Type=Application
          DesktopNames=${lib.concatStringsSep ";" session.desktopNames}
        '';

        # Similarly to the desktop session template, this is also set as a
        # static template.
        sessionScript = ''
          #!${pkgs.runtimeShell}

          # gnome-session is also looking for RequiredComponents in here.
          XDG_CONFIG_DIRS=@out@/etc/xdg''${XDG_CONFIG_DIRS:-:$XDG_CONFIG_DIRS}

          # We'll have to force gnome-session to detect our session.
          XDG_DATA_DIRS=@out@/share''${XDG_DATA_DIRS:-:$XDG_DATA_DIRS}

          ${lib.getExe' cfg.package "gnome-session"} ${lib.escapeShellArgs session.extraArgs}
        '';

        installDesktopFiles =
          lib.mapAttrsToList
            (name: component:
              let
                desktopPackage = pkgs.makeDesktopItem component.desktopConfig;
              in
              ''
                install -Dm0644 ${desktopPackage}/share/applications/*.desktop -t $out/share/applications
              '')
            session.components;
      in
      pkgs.runCommand "${session.name}-desktop-session-files"
        {
          env = {
            inherit (session) fullName;
          };
          inherit displaySession gnomeSession sessionScript;
          passAsFile = [ "displaySession" "sessionScript" ];
          passthru.providedSessions = [ session.name ];
        }
        ''
          SESSION_SCRIPT="$out/libexec/${session.name}-session"
          install -Dm0755 "$sessionScriptPath" "$SESSION_SCRIPT"
          substituteAllInPlace "$SESSION_SCRIPT"

          GNOME_SESSION_FILE="$out/share/gnome-session/sessions/${session.name}.session"
          install -Dm0644 "$gnomeSession" "$GNOME_SESSION_FILE"

          DISPLAY_SESSION_FILE="$out/share/wayland-sessions/${session.name}.desktop"
          install -Dm0644 "$displaySessionPath" "$DISPLAY_SESSION_FILE"
          substituteAllInPlace "$DISPLAY_SESSION_FILE"

          ${lib.concatStringsSep "\n" installDesktopFiles}
        ''
    )
    cfg.sessions;

  sessionSystemdUnits = lib.concatMapAttrs
    (_: session:
      let
        inherit (utils.systemdUtils.lib)
          pathToUnit serviceToUnit targetToUnit timerToUnit socketToUnit;

        mkSystemdUnits = name: component: {
          "${component.id}.service" = serviceToUnit component.systemd.serviceUnit;
          "${component.id}.target" = targetToUnit component.systemd.targetUnit;
        } // lib.optionalAttrs (component.systemd.socketUnit != null) {
          "${component.id}.socket" = socketToUnit component.systemd.socketUnit;
        } // lib.optionalAttrs (component.systemd.timerUnit != null) {
          "${component.id}.timer" = timerToUnit component.systemd.timerUnit;
        } // lib.optionalAttrs (component.systemd.pathUnit != null) {
          "${component.id}.path" = pathToUnit component.systemd.pathUnit;
        };

        componentsUnits = lib.concatMapAttrs mkSystemdUnits session.components;
      in
      componentsUnits // {
        "gnome-session@${session.name}.target" = targetToUnit session.systemd.targetUnit;
      }
    )
    cfg.sessions;
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
      type = with lib.types; attrsOf (submoduleWith {
        specialArgs = { inherit utils glibKeyfileFormat pkgs; };
        modules = [ ./submodules/session-type.nix ];
        shorthandOnlyDefinesConfig = true;
      });
      description = ''
        A set of desktop sessions to be created with
        {manpage}`gnome-session(1)`. This gnome-session configuration generates
        both the `.desktop` file and systemd units to be able to support both
        the built-in and the systemd-managed GNOME session.

        Each of the attribute name will be used as the identifier of the
        desktop environment.

        ::: {.tip}
        While you can make identifiers in any way, it is encouraged to stick to
        a naming scheme. The recommended method is a reverse DNS-like scheme
        preferably with a domain name you own (e.g.,
        `com.example.MoseyBranch`).
        :::
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

  config = lib.mkIf (cfg.sessions != { }) {
    # Install all of the desktop session files.
    services.displayManager.sessionPackages = sessionPackages;
    environment.systemPackages = [ cfg.package ] ++ sessionPackages;

    # Make sure it is searchable within gnome-session.
    environment.pathsToLink = [ "/share/gnome-session" ];

    # Import those systemd units from gnome-session as well.
    systemd.packages = [ cfg.package ];

    # We could include the systemd units in the desktop session package (which
    # is more elegant and surprisingly trivial) but this requires
    # reimplementing parts of nixpkgs systemd-lib and we're lazy bastards so
    # no.
    systemd.user.units = sessionSystemdUnits;
  };
}
