{ name, config, pkgs, lib, utils, sessiondPkg, ... }:

let
  # For an updated list, see `menu/menu-spec.xml` from
  # https://gitlab.freedesktop.org/xdg/xdg-specs.
  validDesktopNames = [
    "GNOME"
    "GNOME-Classic"
    "GNOME-Flashback"
    "KDE"
    "LXDE"
    "LXQt"
    "MATE"
    "Razor"
    "ROX"
    "TDE"
    "Unity"
    "XFCE"
    "EDE"
    "Cinnamon"
    "Pantheon"
    "Budgie"
    "Enlightenment"
    "DDE"
    "Endless"
    "Old"
  ];

  # This is used both as the configuration format for sessiond.conf and its
  # hooks.
  settingsFormat = pkgs.formats.toml { };
  sessionSettingsFile = settingsFormat.generate "sessiond-conf-${config.name}" config.settings;
in
{
  options = {
    name = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = ''
        The identifier for the desktop environment.

        ::: {.note}
        While there is no formal standard for naming these, it is recommended
        to make the name in kebab-case (for example, "mosey-branch" for "Mosey
        branch").
        :::
      '';
      default = name;
      example = "mosey-branch";
    };

    fullName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "The display name of the desktop environment.";
      default = name;
      example = "Mosey Branch";
    };

    desktopNames = lib.mkOption {
      type = with lib.types; listOf nonEmptyStr;
      description = ''
        Names to be used as `DesktopNames=` entry of the session `.desktop`
        file. Useful if you're creating a customized version of an already
        existing desktop session.

        ::: {.note}
        This module sanitizes the values by prepending the given names with
        `X-` if they aren't part of the registered values from XDG spec.
        :::
      '';
      default = [ config.fullName ];
      defaultText = "[ <session>.fullName ]";
      apply = names:
        builtins.map
          (name:
            if (lib.elem name validDesktopNames) || (lib.hasPrefix "X-" name) then
              name
            else
              "X-${name}")
          names;
      example = [ "GNOME" "Garden" ];
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      example = {
        Idle = {
          Inputs = [ "motion" "button-press" ];
          IdleSec = 60;
        };

        Lock = {
          OnIdle = true;
          OnSleep = true;
        };

        DPMS.Enable = true;
      };
      description = ''
        The settings associated with the sessiond session. For more
        details, please see {manpage}`sessiond.conf(5)`. If not given, it
        will use the default configuration from the compiled package.
      '';
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
        specialArgs = {
          inherit utils;
          session = {
            inherit (config) fullName desktopNames description;
            inherit name;
          };
        };
        modules = [ ./component-type.nix ];
      });
      description = ''
        The individual components to be launched with the desktop session.
      '';
      default = { };
      example = lib.literalExpression ''
        {
        }
      '';
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
        `<name>.target`.

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
      visible = "shallow";
      default = { };
      defaultText = ''
        {
          wants = ... # All of the required components as a target unit.
        }
      '';
    };

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
      default = { };
      visible = "shallow";
      description = ''
        systemd service configuration to be generated for the sessiond session
        itself.

        :::{.note}
        This has the same options as {option}`systemd.user.services.<name>`
        but without certain options from stage 2 counterparts such as
        `reloadTriggers` and `restartTriggers`.

        By default, this module sets the service unit as part of the respective
        target unit (i.e., `PartOf=$COMPONENTID.target`).

        On a typical case, you shouldn't mess with much of the dependency
        ordering with the service unit. You should configure `targetUnit` for
        that instead.
        :::
      '';
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        A list of arguments from {command}`sessiond` to be added for the session
        script.
      '';
      default = [ ];
      example = lib.literalExpression ''
        [
          "--hooksd=''${./config/sessiond/hooks.d}"
        ]
      '';
    };
  };

  # Append the session argument.
  config = {
    extraArgs = lib.optional (config.settings != { }) "--config=${sessionSettingsFile}";

    targetUnit = {
      description = config.description;
      requires = [ "${config.name}.service" ];
      wants =
        let
          componentTargetUnits =
            lib.mapAttrsToList (_: component: "${component.id}.target") config.components;
        in
        componentTargetUnits;
    };

    serviceUnit = {
      description = config.description;
      partOf = [ "${config.name}.target" ];
      before = [ "${config.name}.target" ];
      requisite = [ "${config.name}.target" ];
      requires = [ "dbus.socket" ];
      after = [ "dbus.socket" ];

      serviceConfig = {
        Slice = lib.mkForce "session.slice";
        Type = lib.mkForce "dbus";
        BusName = lib.mkForce "org.sessiond.session1";
        ExecStart = lib.mkForce "${lib.getExe' sessiondPkg "sessiond"} ${lib.concatStringsSep " " config.extraArgs}";
        Restart = "always";
      };

      unitConfig = {
        RefuseManualStart = true;
        RefuseManualStop = true;
      };
    };
  };
}
