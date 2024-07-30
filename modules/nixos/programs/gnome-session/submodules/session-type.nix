{ name, config, pkgs, lib, utils, glibKeyfileFormat, ... }:

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
in
{
  options = {
    name = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = ''
        The identifier of the desktop environment to be used for the filenames
        of related outputs.

        ::: {.note}
        While there is no formal specification around naming them, a common
        convention is to use kebab-casing of the name (e.g., "mosey-branch" for
        "Mosey Branch").
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
        `X-` if they aren't part of the registered values from XDG spec. This
        is because the desktop components' `.desktop` file are being
        validated with `desktop-file-validate` from xdg-file-utils.
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
          inherit utils pkgs;
          session = {
            inherit (config) fullName desktopNames description;
            inherit name;
          };
        };
        modules = [ ./component-type.nix ];
        shorthandOnlyDefinesConfig = true;
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
        A list of arguments from {command}`gnome-session` to be added for the session
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

    settings = lib.mkOption {
      type = glibKeyfileFormat.type;
      description = ''
        Settings to be included to the gnome-session keyfile of the session.

        Generally, you won't need to set this since the module will set the
        common settings such as the `RequiredComponents=` key.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          "GNOME Session" = {
            # A helper script to check if the session is runnable.
            IsRunnableHelper = "''${lib.getExe' pkgs.niri "niri"} --validate config";

            # A fallback session in case it failed.
            FallbackSession = "gnome";
          };
        }
      '';
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

        The only time you manually set this if you want to require other
        gnome-session components from other desktop such as when creating a
        customized version of GNOME.
        :::
      '';
      default = lib.mapAttrsToList (_: component: component.id) config.components;
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
      visible = "shallow";
      defaultText = ''
        {
          wants = ... # All of the required components as a target unit.
        }
      '';
    };
  };

  config = {
    # Append the session argument.
    extraArgs = [ "--session=${name}" ];

    targetUnit = {
      overrideStrategy = lib.mkForce "asDropin";
      wants = lib.mkDefault (builtins.map (c: "${c}.target") config.requiredComponents);
    };

    settings."GNOME Session" = {
      Name = lib.mkDefault "${config.fullName} session";
      RequiredComponents = config.requiredComponents;
    };
  };
}
