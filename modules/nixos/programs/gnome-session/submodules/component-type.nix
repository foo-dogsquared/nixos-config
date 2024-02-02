{ name, config, lib, utils, session, ... }:

let
  optionalSystemdUnitOption = type: systemdModuleAttribute:
    lib.mkOption {
      description = ''
        An optional systemd ${type} configuration to be generated. This should
        be configured if the session is managed by systemd.

        :::{.note}
        This has the same options as
        {option}`systemd.user.${systemdModuleAttribute}.<name>` but without
        certain options from stage 2 counterparts such as `reloadTriggers` and
        `restartTriggers`.
        :::
      '';
      default = null;
    };
in
{
  options = {
    description = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "One-sentence description of the component.";
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

        By default, this module sets the service unit as part of the respective
        target unit (i.e., `PartOf=$COMPONENTID.target`).

        On a typical case, you shouldn't mess with much of the dependency
        ordering of the service unit. You should configure `targetUnit` for
        that instead.
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

    timerUnit = optionalSystemdUnitOption "timer" "timers" // {
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
    };

    socketUnit = optionalSystemdUnitOption "socket" "sockets" // {
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
    };

    pathUnit = optionalSystemdUnitOption "path" "paths" // {
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
    };

    id = lib.mkOption {
      type = lib.types.str;
      description = ''
        The identifier of the component used in generating filenames for its
        `.desktop` files and as part of systemd unit names.
      '';
      default = "${session.name}.${name}";
      defaultText = "\${session-name}.\${name}";
      readOnly = true;
    };
  };

  config = {
    # Make with the default configurations for the built-in-managed
    # components.
    desktopConfig = {
      name = lib.mkForce config.id;
      desktopName = lib.mkDefault "${session.fullName} - ${config.description}";
      noDisplay = lib.mkForce true;
      onlyShowIn = session.desktopNames;
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

      * Even if we have a way to limit starting desktop components with
      `systemd-xdg-autostart-condition`, using `Service.ExecCondition=`
      would severely limit possible reuse of desktop components with other
      NixOS-module-generated gnome-session sessions so we're not bothering
      with those.

      TODO: Is `Type=notify` a good default?
      * `Service.Type=` is obviously not included since not all desktop
      components are the same either. Some of them could be a D-Bus service,
      some of them are oneshots, etc. Though, it might be better to have this
      as an explicit option set by the user instead of setting `Type=notify` as
      a default.

      TODO: A good balance for this value, probably?
      * `Service.OOMScoreAdjust=` have different values for different
      components so it isn't included.

      * Most sandboxing options. Aside from the fact we're dealing with a
      systemd user unit, much of them are unnecessary and rarely needed (if
      ever like `Service.PrivateTmp=`?) so we didn't set such defaults here.
    */
    serviceUnit = {
      script = lib.mkAfter config.script;
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
      Take note the session target unit already has `Wants=$COMPONENT.target`
      so no need to set dependency ordering directives here.
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
  };
}
