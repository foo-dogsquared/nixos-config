{ config, lib, pkgs, utils, ... }:

let
  cfg = config.programs.gnome-session;
in
rec {
  componentsType = { name, config, options, session, ... }: {
    options = {
      description = lib.mkOption {
        type = lib.types.nonEmptyStr;
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
        default = { };
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
        default = { };
      };

      timerUnit = lib.mkOption {
        type =
          let
            inherit (utils.systemdUtils.unitOptions) timerOptions commonUnitOptions;
            inherit (utils.systemdUtils.lib) unitConfig;
          in
          with lib.types; nullOr (submodule [
            commonUnitOptions
            timerOptions
            unitConfig
          ]);
        description = ''
          An optional systemd timer configuration to be generated. This should
          be configured if the session is managed by systemd.

          :::{.note}
          This has the same options as {option}`systemd.user.timers.<name>`
          but without certain options from stage 2 counterparts such as
          `reloadTriggers` and `restartTriggers`.
          :::
        '';
        default = null;
      };

      socketUnit = lib.mkOption {
        type =
          let
            inherit (utils.systemdUtils.unitOptions) socketOptions commonUnitOptions;
            inherit (utils.systemdUtils.lib) unitConfig;
          in
          with lib.types; nullOr (submodule [
            commonUnitOptions
            socketOptions
            unitConfig
          ]);
        description = ''
          An optional systemd socket configuration to be generated. This should
          be configured if the session is managed by systemd.

          :::{.note}
          This has the same options as {option}`systemd.user.sockets.<name>`
          but without certain options from stage 2 counterparts such as
          `reloadTriggers` and `restartTriggers`.
          :::
        '';
        default = null;
      };

      pathUnit = lib.mkOption {
        type =
          let
            inherit (utils.systemdUtils.unitOptions) pathOptions commonUnitOptions;
            inherit (utils.systemdUtils.lib) unitConfig;
          in
          with lib.types; nullOr (submodule [
            commonUnitOptions
            pathOptions
            unitConfig
          ]);
        description = ''
          An optional systemd path configuration to be generated. This should
          be configured if the session is managed by systemd.

          :::{.note}
          This has the same options as {option}`systemd.user.paths.<name>`
          but without certain options from stage 2 counterparts such as
          `reloadTriggers` and `restartTriggers`.
          :::
        '';
        default = null;
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

    config =
      let
        scriptName = "${session.name}-${name}-script";
        script = "${config.scriptPackage}/bin/${scriptName}";
      in
      {
        id = "${session.name}.${name}";

        # Make with the default configurations for the built-in-managed
        # components.
        desktopConfig = {
          name = lib.mkForce config.id;
          desktopName = lib.mkDefault "${session.fullName} - ${config.description}";
          exec = lib.mkForce script;
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

          * Most sandboxing options. Aside from the fact we're dealing with a
          systemd user unit, much of them are unnecessary and rarely needed (if
          ever like `Service.PrivateTmp=`?) so we didn't set such defaults here.

          As you can tell, this module does not provide a framework for the user
          to easily compose their own desktop environment. THIS MODULE ALREADY
          DOES A LOT, ALRIGHT! CUT ME SOME SLACK!

          Take note that the default service configuration is leaning on the
          desktop component being a simple type of service like how most NixOS
          service modules are deployed.
        */
        serviceUnit = {
          script = lib.mkAfter script;
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

          startLimitBurst = lib.mkDefault 3;
          startLimitIntervalSec = lib.mkDefault 15;

          unitConfig = {
            # Units managed by gnome-session are required to have CollectMode=
            # set to this value.
            CollectMode = lib.mkForce "inactive-or-failed";

            # We leave those up to the target units to start the services.
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
          name = scriptName;
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
        type = lib.types.nonEmptyStr;
        description = "The (formal) name of the desktop environment.";
        default = name;
        example = "Mosey Branch";
      };

      display = lib.mkOption {
        type = with lib.types; listOf (enum [ "wayland" "xorg" ]);
        description = ''
          A list of display server protocols supported by the desktop
          environment.
        '';
        default = [ "wayland" ];
        example = [ "wayland" "xorg" ];
      };

      description = lib.mkOption {
        type = lib.types.nonEmptyStr;
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
          The individual components to be launched with the desktop session.
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
          A list of arguments from {program}`gnome-session` to be added for the session
          script.

          ::: {.note}
          An argument `--session=<name>` will always be appended into the
          configuration.
          :::
        '';
        example = [
          "--systemd"
          "--disable-acceleration-check"
        ];
      };

      requiredComponents = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          A list of desktop components as part of `RequiredComponents=` for the
          gnome-session configuration.

          ::: {.note}
          For the most part, this shouldn't require manually configuring it if
          you set {option}`<session>.components` as this module already sets
          them for you.

          The only time you manually set this if you want to require components
          from other desktop such as when creating a customized version of
          GNOME.
          :::
        '';
        example = [
          "org.gnome.Shell"
          "org.gnome.SettingsDaemon.A11ySettings"
          "org.gnome.SettingsDaemon.Power"
          "org.gnome.SettingsDaemon.Wacom"
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
          systemd target configuration to be generated for
          `gnome-session@<name>.target`. This should be configured if the
          session is managed by systemd and you want to control the session
          further (which is recommended since this module don't know what
          components are more important, etc.).

          By default, the session target will have all of its components from
          {option}`<session>.requiredComponents` under `Wants=` directive. It
          also assumes all of them have a target unit at
          `''${requiredComponent}.target`.

          :::{.note}
          This has the same options as {option}`systemd.user.targets.<name>`
          but without certain options from stage 2 counterparts such as
          `reloadTriggers` and `restartTriggers`.
          :::
        '';
        defaultText = ''
          {
            wants = ... # All of the required components as a target unit.
          }
        '';
      };

      sessionPackage = lib.mkOption {
        type = lib.types.package;
        description = ''
          The collective package containing everything desktop-related
          such as:

          * The display session (`<name>.desktop`) files.
          * gnome-session `.session` file.
          * The gnome-session systemd target drop-in file.
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
          inherit (utils.systemdUtils.lib)
            pathToUnit serviceToUnit targetToUnit timerToUnit socketToUnit;
          componentsUnits =
            lib.foldlAttrs
              (acc: name: component:
                acc // {
                  "${component.id}.service" = serviceToUnit component.id component.serviceUnit;
                  "${component.id}.target" = targetToUnit component.id component.targetUnit;
                } // lib.optionalAttrs (component.socketUnit != null) {
                  "${component.id}.socket" = socketToUnit component.id component.socketUnit;
                } // lib.optionalAttrs (component.timerUnit != null) {
                  "${component.id}.timer" = timerToUnit component.id component.timerUnit;
                } // lib.optionalAttrs (component.pathUnit != null) {
                  "${component.id}.path" = pathToUnit component.id component.pathUnit;
                })
              { }
              config.components;
        in
        componentsUnits // {
          "gnome-session@${name}.target" = targetToUnit "gnome-session@${name}" config.targetUnit;
        };

      # By default. set the required components from the given desktop
      # components.
      requiredComponents = lib.mapAttrsToList (_: component: component.id) config.components;

      targetUnit = {
        overrideStrategy = lib.mkForce "asDropin";
        wants = lib.mkDefault (builtins.map (c: "${c}.target") config.requiredComponents);
      };

      # The bulk of the work. Pretty much the main purpose of this module.
      sessionPackage =
        let
          gnomeSession = ''
            [GNOME Session]
            Name=${config.fullName} session
            RequiredComponents=${lib.concatStringsSep ";" config.requiredComponents};
          '';

          displaySession = ''
            [Desktop Entry]
            Name=@fullName@
            Comment=${config.description}
            Exec="@out@/libexec/${name}-session"
            Type=Application
            DesktopNames=X-${config.fullName};
          '';

          sessionScript = ''
            #!${pkgs.runtimeShell}

            # gnome-session is also looking for RequiredComponents in here.
            XDG_CONFIG_DIRS=@out@/etc/xdg''${XDG_CONFIG_DIRS:-:$XDG_CONFIG_DIRS}

            # We'll have to force gnome-session to detect our session.
            XDG_DATA_DIRS=@out@/share''${XDG_DATA_DIRS:-:$XDG_DATA_DIRS}

            ${lib.getExe' cfg.package "gnome-session"} ${lib.escapeShellArgs config.extraArgs}
          '';

          displayScripts =
            let
              hasMoreDisplays = protocol: lib.optionalString (lib.length config.display > 1) "fullName='${config.fullName} (${protocol})'";
            in
            {
              wayland = ''
                (
                  DISPLAY_SESSION_FILE="$out/share/wayland-sessions/${name}.desktop"
                  install -Dm0644 "$displaySessionPath" "$DISPLAY_SESSION_FILE"
                  ${hasMoreDisplays "Wayland"} substituteAllInPlace "$DISPLAY_SESSION_FILE"
                )
              '';
              xorg = ''
                (
                  DISPLAY_SESSION_FILE="$out/share/xsessions/${name}.desktop"
                  install -Dm0644 "$displaySessionPath" "$DISPLAY_SESSION_FILE"
                  ${hasMoreDisplays "X11"} substituteAllInPlace "$DISPLAY_SESSION_FILE"
                )
              '';
            };

          installDesktopSessions = builtins.map
            (display:
              displayScripts.${display})
            config.display;

          installSystemdUserUnits = lib.mapAttrsToList
            (n: v:
              if (v ? overrideStrategy && v.overrideStrategy == "asDropin") then ''
                (
                  unit="${v.unit}/${n}"
                  unit_filename=$(basename "$unit")
                  install -Dm0644 "$unit" "$out/share/systemd/user/''${unit_filename}.d/session.conf"
                )
              '' else ''
                install -Dm0644 "${v.unit}/${n}" -t "$out/share/systemd/user"
              '')
            config.systemdUserUnits;

          installDesktops = lib.mapAttrsToList
            (_: p: ''
              install -Dm0644 ${p.desktopPackage}/share/applications/*.desktop -t $out/share/applications
            '')
            config.components;
        in
        pkgs.runCommandLocal "${name}-desktop-session-files"
          {
            env = {
              inherit (config) fullName;
            };
            inherit displaySession gnomeSession sessionScript;
            passAsFile = [ "displaySession" "gnomeSession" "sessionScript" ];
            passthru.providedSessions = [ name ];
          }
          ''
            SESSION_SCRIPT="$out/libexec/${name}-session"
            install -Dm0755 "$sessionScriptPath" "$SESSION_SCRIPT"
            substituteAllInPlace "$SESSION_SCRIPT"

            GNOME_SESSION_FILE="$out/share/gnome-session/sessions/${name}.session"
            install -Dm0644 "$gnomeSessionPath" "$GNOME_SESSION_FILE"
            substituteAllInPlace "$GNOME_SESSION_FILE"

            ${lib.concatStringsSep "\n" installDesktopSessions}

            ${lib.concatStringsSep "\n" installSystemdUserUnits}
            mkdir -p "$out/lib/systemd" && ln -sfn "$out/share/systemd/user" "$out/lib/systemd/user"

            ${lib.concatStringsSep "\n" installDesktops}
          '';
    };
  };
}
