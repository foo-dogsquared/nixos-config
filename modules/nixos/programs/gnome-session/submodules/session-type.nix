{ name, config, lib, utils, ... }:

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

    display = lib.mkOption {
      type = with lib.types; listOf (enum [ "wayland" "x11" ]);
      description = ''
        A list of display server protocols supported by the desktop
        environment.
      '';
      default = [ "wayland" ];
      example = [ "wayland" "x11" ];
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

        The only time you manually set this if you want to require other
        gnome-session components from other desktop such as when creating a
        customized version of GNOME.
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
        * The components `.desktop` file.
      '';
      readOnly = true;
    };
  };

  config = {
    # Append the session argument.
    extraArgs = [ "--session=${name}" ];

    # By default. set the required components from the given desktop
    # components.
    requiredComponents = lib.mapAttrsToList (_: component: component.id) config.components;

    targetUnit = {
      overrideStrategy = lib.mkForce "asDropin";
      wants = lib.mkDefault (builtins.map (c: "${c}.target") config.requiredComponents);
    };
  };
}
