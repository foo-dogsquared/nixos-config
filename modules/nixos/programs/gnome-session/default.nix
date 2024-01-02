{ config, lib, pkgs, utils, ... }:

# TODO: Generate the systemd units and place them in the desktop session package.
let
  cfg = config.programs.gnome-session;

  componentsType = { name, config, options, session, ... }: {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "One-sentence description of the component.";
        default = "";
        example = "Desktop widgets";
      };

      script = lib.mkOption {
        type = lib.types.lines;
        description = ''
          The script of the component. Take note this will be wrapped in a
          script for proper integration with `gnome-session`.
        '';
      };

      desktopConfig = lib.mkOption {
        type = with lib.types; attrsOf anything;
        description = ''
          The configuration for the gnome-session desktop file. For more
          information, look into `makeDesktopItem` nixpkgs builder.

          You should configure this is if you use the built-in service
          management to be able to customize the session.

          ::: {.note}
          This module appends several options for the desktop item builder such
          as the script path and `X-GNOME-HiddenUnderSystemd` which is set to
          `true`.
          :::
        '';
        default = { };
        example = {
          extraConfig = {
            X-GNOME-Autostart-Phase = "WindowManager";
            X-GNOME-AutoRestart = "true";
          };
        };
      };

      serviceConfig = lib.mkOption {
        type = lib.types.attrsOf utils.systemdUtils.unitOptions.unitOption;
        description = ''
          systemd service configuration to be used in
          {option}`systemd.user.services.<name>`.

          This should be configured if the session is managed by systemd.
        '';
        default = {};
      };

      targetConfig = lib.mkOption {
        type = lib.types.attrsOf utils.systemdUtils.unitOptions.unitOption;
        description = ''
          systemd target configuration to be used in
          {option}`systemd.user.target.<name>`.

          This should be configured if the session is managed by systemd.
        '';
        default = {};
      };

      id = lib.mkOption {
        type = lib.types.str;
        description = ''
          The identifier of the component used in generating filenames for its
          `.desktop` files and as part of systemd unit names.
        '';
        defaultText = "$${session.name}.$${name}";
        readOnly = true;
      };

      scriptPackage = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        internal = true;
        description = ''
          The package containing a wrapped script of the component script.
        '';
      };

      desktopPackage = lib.mkOption {
        type = lib.types.package;
        internal = true;
        readOnly = true;
        description = ''
          A package containing the desktop item set with
          {option}`desktopSessions.gnome-session.sessions.<name>.components.<name>.desktopConfig`.
        '';
      };
    };

    config = {
      id = "${session.prefix}.${name}";

      # Make with the default configurations.
      desktopConfig = {
        name = lib.mkForce config.id;
        desktopName = lib.mkDefault "${session.fullName} - ${config.description}";
        exec = lib.mkForce config.scriptPackage;
        noDisplay = lib.mkForce true;
        onlyShowIn = [ "X-${session.fullName}" ];
        extraConfig = {
          X-GNOME-AutoRestart = lib.mkDefault "false";
          X-GNOME-Autostart-Notify = lib.mkDefault "true";
          X-GNOME-Autostart-Phase = lib.mkDefault "Application";
          X-GNOME-HiddenUnderSystemd = lib.mkDefault "true";
        };
      };

      # Setting some recommendation and requirements for systemd-managed
      # gnome-session components.
      serviceConfig = {
        script = lib.mkAfter "${config.scriptPackage}/bin/${session.prefix}-${name}-script";
        description = lib.mkDefault config.description;

        path = [ cfg.package ];
        serviceConfig = {
          Slice = lib.mkDefault "session.slice";
          Restart = lib.mkDefault "on-failure";
          TimeoutStopSec = lib.mkDefault 5;
        };
        unitConfig = {
          # Units managed by gnome-session are required to have CollectMode=
          # set to this value.
          CollectMode = lib.mkForce "inactive-or-failed";
          RefuseManualStart = lib.mkDefault true;
          RefuseManualStop = lib.mkDefault true;
        };
      };

      targetConfig = {
        description = lib.mkDefault config.description;
        documentation = [
          "man:gnome-session(1)"
          "man:systemd.special(7)"
        ];
        unitConfig.CollectMode = lib.mkForce "inactive-or-failed";
      };

      scriptPackage = pkgs.writeShellApplication {
        name = "${session.prefix}-${name}-script";
        runtimeInputs = [ cfg.package pkgs.dbus ];
        text = ''
          DESKTOP_AUTOSTART_ID="''${DESKTOP_AUTOSTART_ID:-}"
          echo "$DESKTOP_AUTOSTART_ID"
          test -n "$DESKTOP_AUTOSTART_ID" && {
            dbus-send --print-reply --session \
              --dest=org.gnome.SessionManager "/org/gnome/SessionManager" \
              org.gnome.SessionManager.RegisterClient \
              "string:${name}" "string:$DESKTOP_AUTOSTART_ID"
          }

          ${config.script}
        '';
      };

      desktopPackage = pkgs.makeDesktopItem config.desktopConfig;
    };
  };

  sessionType = { name, config, options, ... }: {
    options = {
      fullName = lib.mkOption {
        type = lib.types.str;
        description = "The (formal) name of the desktop environment.";
        default = name;
        example = "Mosey Branch";
      };

      prefix = lib.mkOption {
        type = lib.types.str;
        description = ''
          The identifier of the desktop environment. While it can be in any
          style, it is encouraged to use a reverse DNS-like scheme.
        '';
        example = "com.example.MoseyBranch";
      };

      description = lib.mkOption {
        type = lib.types.str;
        description = ''
          A one-sentence description of the desktop environment.
        '';
        default = "${config.fullName} desktop environment";
        defaultText = lib.literalExpression "$${<name>.fullName} desktop environment";
        example = "A desktop environment featuring a scrolling compositor.";
      };

      components = lib.mkOption {
        type = with lib.types; attrsOf (submoduleWith {
          specialArgs.session = {
            inherit (config) fullName prefix description;
            inherit name;
          };
          modules = [ componentsType ];
        });
        description = ''
          The individual components to be launched with the desktop session. It
          is heavily patterned after gnome-session.
        '';
        default = { };
        example = lib.literalExpression ''
          {
            window-manager = {
              script = '''
                $${lib.getExe' config.programs.sway.package "sway"}
              ''';
              description = "An i3 clone for Wayland.";
            };

            desktop-widgets.script = '''
              $${lib.getExe' pkgs.ags "ags"} --config $${./config.js}
            ''';
          }
        '';
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          A list of arguments to be added for the session script.

          ::: {.note}
          An argument `--session=<name>` will always be appended into the
          script.
          :::
        '';
        default = [ "--systemd" ];
        example = [
          "--builtin"
          "--disable-acceleration-check"
        ];
      };

      targetConfig = lib.mkOption {
        type = lib.types.attrsOf utils.systemdUtils.unitOptions.unitOption;
        description = ''
          systemd target configuration to be used in
          {option}`systemd.user.target."gnome-session@<name>"`.

          This should be configured if the session is managed by systemd and
          you want to control the session further (which is recommended since
          this module don't know what components are more important, etc.).
        '';
        default = {
          description = "${config.fullName} desktop environment";
          wants = lib.mapAttrsToList (_: component: "${component.id}.target") config.components;
        };
        defaultText = ''
          {
            description = "$${config.fullName} desktop environment";
            wants = ... # All of the components.
          }
        '';
      };

      sessionPackage = lib.mkOption {
        type = lib.types.package;
        description = ''
          The collective package containing everything (except the systemd
          units) desktop-related files such as the Wayland session file,
          gnome-session `.session` file, and the components `.desktop` file.
        '';
        internal = true;
        readOnly = true;
      };
    };

    config = {
      sessionPackage =
        let
          installDesktops = lib.mapAttrsToList
            (_: p: ''
              install -Dm0644 ${p.desktopPackage}/share/applications/*.desktop -t $out/share/applications
            '')
            config.components;

          requiredComponents = lib.mapAttrsToList
            (_: component: component.id)
            config.components;

          gnomeSession = ''
            [GNOME Session]
            Name=${config.fullName} session
            RequiredComponents=${lib.concatStringsSep ";" requiredComponents};
          '';

          waylandSession = ''
            [Desktop Entry]
            Name=${config.fullName}
            Comment=${config.description}
            Exec=@out@/libexec/${name}-session
            Type=Application
          '';

          sessionScript = ''
            #!${pkgs.runtimeShell}

            # gnome-session is also looking for RequiredComponents in here.
            XDG_CONFIG_DIRS=@out@/etc/xdg''${XDG_CONFIG_DIRS:-:$XDG_CONFIG_DIRS}

            # We'll have to force gnome-session to detect our session.
            XDG_DATA_DIRS=@out@/share''${XDG_DATA_DIRS:-:$XDG_DATA_DIRS}

            ${lib.getExe' cfg.package "gnome-session"} ${lib.escapeShellArgs config.extraArgs}
          '';
        in
        pkgs.runCommandLocal "${name}-desktop-session-files"
          {
            inherit waylandSession gnomeSession sessionScript;
            passAsFile = [ "waylandSession" "gnomeSession" "sessionScript" ];
            passthru.providedSessions = [ name ];
          }
          ''
            SESSION_SCRIPT="$out/libexec/${name}-session"
            GNOME_SESSION_FILE="$out/share/gnome-session/sessions/${name}.session"
            WAYLAND_SESSION_FILE="$out/share/wayland-sessions/${name}.desktop"

            install -Dm0755 "$sessionScriptPath" "$SESSION_SCRIPT"
            substituteAllInPlace "$SESSION_SCRIPT"

            install -Dm0644 "$gnomeSessionPath" "$GNOME_SESSION_FILE"
            substituteAllInPlace "$GNOME_SESSION_FILE"

            install -Dm0644 "$waylandSessionPath" "$WAYLAND_SESSION_FILE"
            substituteAllInPlace "$WAYLAND_SESSION_FILE"

            ${lib.concatStringsSep "\n" installDesktops}
          '';
    };
  };
in
{
  options.programs.gnome-session = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gnome.gnome-session;
      defaultText = "pkgs.gnome.gnome-session";
      description = ''
        The package containing gnome-session binary and systemd units. This
        also contains the `gnome-session` executable used for the generated
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
      '';
      default = { };
      example = lib.literalExpression ''
        {
          simple-way = {
            prefix = "one.foodogsquared.SimpleWay";
            components = {
              window-manager = {
                script = '''
                  $${lib.getExe' config.programs.sway.package "sway"}
                ''';
                description = "An i3 clone for Wayland.";
              };

              desktop-widgets = {
                script = '''
                  $${lib.getExe' pkgs.ags "ags"} --config $${./config.js}
                ''';
                description = "A desktop widget system using layer-shell protocol.";
              };

              auth-agent = {
                script = '''
                  $${lib.getExe' pkgs.polkit_gnome "polkit-gnome-authentication-agent-1"}
                ''';
                description = "Polkit authentication agent";
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

        generateServiceBundle = acc: name: session:
          let
            services =
              lib.mapAttrs'
                generateComponentService
                session.components;

            generateComponentService = name: component:
              let
                serviceConfig = lib.mkMerge [
                  {
                    before = [ "${component.id}.target" ];
                    partOf = [ "${component.id}.target" ];
                  }
                  component.serviceConfig
                ];
              in
              lib.nameValuePair component.id serviceConfig;
          in
          acc // services;

        generateTargetBundle = acc: name: session:
          let
            targets =
              lib.mapAttrs'
                generateComponentTarget
                session.components;

            generateComponentTarget = name: component:
              let
                targetConfig = lib.mkMerge [
                  {
                    wants = [ "${component.id}.service" ];
                  }
                  component.targetConfig
                ];
              in
              lib.nameValuePair component.id targetConfig;
          in
          acc // targets // {
            "gnome-session@${name}" = session.targetConfig;
          };
      in
      {
        # Install all of the desktop session files.
        services.xserver.displayManager.sessionPackages = sessionPackages;
        environment.systemPackages = sessionPackages;

        # Make sure it is searchable within gnome-session.
        environment.pathsToLink = [ "/share/gnome-session" ];

        # Import those systemd units from gnome-session as well.
        systemd.packages = [ cfg.package ]; #++ sessionPackages;

        # Most importantly for systemd-managed gnome-session sessions, generate
        # those services.
        systemd.user.services = lib.foldlAttrs generateServiceBundle { } cfg.sessions;
        systemd.user.targets = lib.foldlAttrs generateTargetBundle { } cfg.sessions;
      }
    );
}
