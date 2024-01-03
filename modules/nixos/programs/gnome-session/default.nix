{ config, lib, pkgs, utils, ... }:

let
  cfg = config.programs.gnome-session;

  # TODO: Modularize these types, it's getting too big.
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
          Shell script fragment of the component. Take note this will be
          wrapped in a script for proper integration with `gnome-session`.
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

      # Most of the systemd config types are trying to eliminate as much of the
      # NixOS systemd extensions as much as possible. For more details, see
      # `config` attribute of the `sessionType`.
      serviceUnit = lib.mkOption {
        type =
          let
            inherit (utils.systemdUtils.lib) unitConfig serviceConfig;
            inherit (utils.systemdUtils.unitOptions) commonUnitOptions serviceOptions;
          in
          lib.types.submodule [
            commonUnitOptions
            serviceOptions
            serviceConfig
            unitConfig
          ];
        description = ''
          systemd service configuration to be generated. This should be
          configured if the session is managed by systemd.

          :::{.note}
          This has the same options as {option}`systemd.user.services.<name>`
          but without certain options from stage 2 counterparts such as
          `reloadTriggers` and `restartTriggers`.

          On a typical case, you shouldn't mess with much of the dependency
          ordering of the service unit. By default, this module sets the
          service unit as part of the respective target unit (i.e.,
          `PartOf=$COMPONENTID.target`).
          :::
        '';
        default = {};
      };

      targetUnit = lib.mkOption {
        type =
          let
            inherit (utils.systemdUtils.lib) unitConfig;
            inherit (utils.systemdUtils.unitOptions) commonUnitOptions;
          in
          lib.types.submodule [
            commonUnitOptions
            unitConfig
          ];
        description = ''
          systemd target configuration to be generated. This should be
          configured if the session is managed by systemd.

          :::{.note}
          This has the same options as {option}`systemd.user.targets.<name>`
          but without certain options from stage 2 counterparts such as
          `reloadTriggers` and `restartTriggers`.

          This module doesn't set the typical dependency ordering relative to
          gnome-session targets. This is on the user to manually set them.
          :::
        '';
        default = {};
      };

      id = lib.mkOption {
        type = lib.types.str;
        description = ''
          The identifier of the component used in generating filenames for its
          `.desktop` files and as part of systemd unit names.
        '';
        defaultText = "\${session-name}.\${name}";
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
          {option}`$SESSION.components.<name>.desktopConfig`.
        '';
      };
    };

    config = {
      id = "${session.name}.${name}";

      # Make with the default configurations for the built-in-managed
      # components.
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

      /*
        Setting some recommendation and requirements for systemd-managed
        gnome-session components. Note there are the missing directives that
        COULD include some sane defaults here.

        * The `Unit.OnFailure=` and `Unit.OnFailureJobMode=` directives. Since
        different components don't have the same priority and don't handle
        failures the same way, we didn't set it here. This is on the user to
        know how different desktop components interact with each other
        especially if one of them failed.

        TODO: Is `Type=notify` a good default?
        * `Service.Type=` is obviously not included since not all desktop
        components are the same either. Some of them could a D-Bus service,
        some of them are oneshots, etc. Not to mention, this is already implied
        to be `Type=simple` by systemd anyways.

        * `Service.OOMScoreAdjust=` have different values for different
        components so it isn't included.

        As you can tell, this module does not provide a framework for the user
        to easily compose their own desktop environment. THIS MODULE ALREADY
        DOES A LOT, ALRIGHT! CUT ME SOME SLACK!
      */
      serviceUnit = {
        script = lib.mkAfter "${config.scriptPackage}/bin/${session.name}-${name}-script";
        description = lib.mkDefault config.description;

        # The typical workflow for service units to have them set as part of
        # the respective target unit.
        requisite = [ "${config.id}.target" ];
        before = [ "${config.id}.target" ];
        partOf = [ "${config.id}.target" ];

        # Some sane service configuration for a desktop component.
        serviceConfig = {
          Slice = lib.mkDefault "session.slice";
          Restart = lib.mkDefault "on-failure";
          TimeoutStopSec = lib.mkDefault 5;
        };

        unitConfig = {
          # Units managed by gnome-session are required to have CollectMode=
          # set to this value.
          CollectMode = lib.mkForce "inactive-or-failed";

          # Some sane unit configurations for systemd-managed desktop
          # components.
          RefuseManualStart = lib.mkDefault true;
          RefuseManualStop = lib.mkDefault true;
        };
      };

      /*
        Similarly, there are things that COULD make it here but didn't for a
        variety of reasons.

        * `Unit.PartOf=`, `Unit.Requisite=`, and the like since some components
        require starting up earlier than the others. We could include it here
        if we make it clear in the documentation or if it proves to be a
        painful experience to configure this by a first-timer. For now, this is
        on the user to know.
      */
      targetUnit = {
        wants = [ "${config.id}.service" ];
        description = lib.mkDefault config.description;
        documentation = [
          "man:gnome-session(1)"
          "man:systemd.special(7)"
        ];
        unitConfig.CollectMode = lib.mkForce "inactive-or-failed";
      };

      scriptPackage = pkgs.writeShellApplication {
        name = "${session.name}-${name}-script";
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

      description = lib.mkOption {
        type = lib.types.str;
        description = ''
          A one-sentence description of the desktop environment.
        '';
        default = "${config.fullName} desktop environment";
        defaultText = lib.literalExpression "\${<name>.fullName} desktop environment";
        example = "A desktop environment featuring a scrolling compositor.";
      };

      components = lib.mkOption {
        type = with lib.types; attrsOf (submoduleWith {
          specialArgs.session = {
            inherit (config) fullName description;
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
                ''${lib.getExe' config.programs.sway.package "sway"}
              ''';
              description = "An i3 clone for Wayland.";
            };

            desktop-widgets.script = '''
              ''${lib.getExe' pkgs.ags "ags"} --config ''${./config.js}
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

      targetUnit = lib.mkOption {
        type =
          let
            inherit (utils.systemdUtils.lib) unitConfig;
            inherit (utils.systemdUtils.unitOptions) commonUnitOptions;
          in
          lib.types.submodule [
            commonUnitOptions
            unitConfig
          ];
        description = ''
          systemd target configuration to be generated. This should be
          configured if the session is managed by systemd and you want to
          control the session further (which is recommended since this module
          don't know what components are more important, etc.).

          :::{.note}
          This has the same options as {option}`systemd.user.targets.<name>`
          but without certain options from stage 2 counterparts such as
          `reloadTriggers` and `restartTriggers`.
          :::
        '';
        defaultText = ''
          {
            wants = ... # All of the components.
          }
        '';
      };

      sessionPackage = lib.mkOption {
        type = lib.types.package;
        description = ''
          The collective package containing everything desktop-related
          such as:

          * The Wayland session file.
          * gnome-session `.session` file.
          * The components `.desktop` file.
          * The components' systemd unit files.
        '';
        readOnly = true;
      };

      systemdUserUnits = lib.mkOption {
        type = utils.systemdUtils.types.units;
        description = ''
          A set of systemd user units to be generated.
        '';
        internal = true;
        readOnly = true;
      };
    };

    config = {
      # Append the session argument.
      extraArgs = [ "--session=${name}" ];

      # While it is tempting to have this delegated to `systemd.user.services`
      # and the like, it does have a future problem regarding how the generated
      # units will handle reload on change since NixOS systemd units lets you
      # have that option. Restricting it ourselves prevent it from doing so.
      #
      # As a (HUGE) bonus, it also leads to a more elegant solution of making
      # an entire package of the desktop environment and simply linking them
      # with various NixOS options like `systemd.packages` and the like.
      systemdUserUnits =
        let
          inherit (utils.systemdUtils.lib) serviceToUnit targetToUnit;
          componentsUnits =
            lib.foldlAttrs (acc: name: component:
              acc // {
                "${component.id}.service" = serviceToUnit component.id component.serviceUnit;
                "${component.id}.target" = targetToUnit component.id component.targetUnit;
              })
              {} config.components;
        in
          componentsUnits // {
            "gnome-session@${name}.target" = targetToUnit "gnome-session@${name}" config.targetUnit;
          };

      targetUnit = {
        overrideStrategy = lib.mkForce "asDropin";
        wants = lib.mkDefault (lib.mapAttrsToList (_: component: "${component.id}.target") config.components);
      };

      sessionPackage =
        let
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
            DesktopNames=${config.fullName};
          '';

          sessionScript = ''
            #!${pkgs.runtimeShell}

            # gnome-session is also looking for RequiredComponents in here.
            XDG_CONFIG_DIRS=@out@/etc/xdg''${XDG_CONFIG_DIRS:-:$XDG_CONFIG_DIRS}

            # We'll have to force gnome-session to detect our session.
            XDG_DATA_DIRS=@out@/share''${XDG_DATA_DIRS:-:$XDG_DATA_DIRS}

            ${lib.getExe' cfg.package "gnome-session"} ${lib.escapeShellArgs config.extraArgs}
          '';

          installSystemdUserUnits = lib.mapAttrsToList (n: v:
            if (v ? overrideStrategy && v.overrideStrategy == "asDropin") then ''
              (
                unit="${v.unit}/${n}"
                unit_filename=$(basename "$unit")
                install -Dm0644 "$unit" "$out/share/systemd/user/''${unit_filename}.d/session.conf"
              )
            '' else ''
              install -Dm0644 "${v.unit}/${n}" -t "$out/share/systemd/user"
            '') config.systemdUserUnits;

          installDesktops = lib.mapAttrsToList
            (_: p: ''
              install -Dm0644 ${p.desktopPackage}/share/applications/*.desktop -t $out/share/applications
            '')
            config.components;
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

            ${lib.concatStringsSep "\n" installSystemdUserUnits}
            mkdir -p "$out/lib/systemd" && ln -sfn "$out/share/systemd/user" "$out/lib/systemd/user"

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
          "one.foodogsquared.SimpleWay" = {
            components = {
              # This unit is intended to start with gnome-session.
              window-manager = {
                script = '''
                  ''${lib.getExe' config.programs.sway.package "sway"}
                ''';
                description = "An i3 clone for Wayland.";
              };

              desktop-widgets = {
                script = '''
                  ''${lib.getExe' pkgs.ags "ags"} --config ''${./config.js}
                ''';
                description = "A desktop widget system using layer-shell protocol.";
              };

              auth-agent = {
                script = '''
                  ''${lib.getExe' pkgs.polkit_gnome "polkit-gnome-authentication-agent-1"}
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
