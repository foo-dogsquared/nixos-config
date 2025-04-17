{ config, lib, pkgs, ... }:

let
  cfg = config.programs.kando;

  settingsFormat = pkgs.formats.json { };
in
{
  options.programs.kando = {
    enable = lib.mkEnableOption "Kando, a pie menu";

    package = lib.mkPackageOption pkgs "kando" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Settings for Kando to be generated at
        {file}`$XDG_CONFIG_HOME/kando/config.json`.
      '';
      example = lib.literalExpression ''
        {
          enableVersionCheck = false;

          menuTheme = "my-menu-theme";
          darkMenuTheme = "my-dark-menu-theme";

          soundTheme = "my-sound-theme";
          soundVolume = 0.8;

          iconTheme = "my-icon-theme";
        }
      '';
    };

    menuSettings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Menu-specific configuration for Kando to be generated at
        {file}`$XDG_CONFIG_HOME/kando/menus.json`.
      '';
      example = lib.literalExpression ''
        {
          menus = [
            {
              shortcut = "Ctrl+Space";
              shortcutId = "example-menu";
              root = {
                type = "submenu";
                name = "example-menu.submenu";
                children = [
                  # ...
                ];
              };
            }

            {
              shortcut = "Super+Space";
              shortcutId = "super-menu";
              root = {
                type = "submenu";
                name = "super-menu.submenu";
                children = [
                  # ...
                ];
              };
            }
          ];
        }
      '';
    };

    themes = let
      mkThemeOption = type: expectedOutputDir:
        lib.mkOption {
          type = with lib.types; listOf package;
          default = [ ];
          description = ''
            A list of packages containing Kando ${type} themes expected at
            {file}`${expectedOutputDir}`.
          '';
          example = lib.literalExpression ''
            with pkgs.kandoThemes; [
              doggo
              catpuccin
            ];
          '';
        };
    in {
      menus = mkThemeOption "menu" "$out/share/kando/menu-themes";
      sounds = mkThemeOption "sound" "$out/share/kando/sound-themes";
      icons = mkThemeOption "icon" "$out/share/kando/icon-themes";
    };

    enableGnomeInegration = lib.mkEnableOption "GNOME Shell integration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ lib.optionals cfg.enableGnomeInegration [
      pkgs.gnomeExtensions.kando-integration
    ];

    xdg.configFile = {
      "kando/config.json" = lib.mkIf (cfg.settings != { }) {
        source = settingsFormat.generate "kando-settings-home-manager" cfg.settings;
      };

      "kando/menus.json" = lib.mkIf (cfg.menuSettings != { }) {
        source = settingsFormat.generate "kando-menu-settings-home-manager" cfg.menuSettings;
      };

      "kando/menu-themes" = lib.mkIf (cfg.themes.menus != [ ]) {
        source = pkgs.buildEnv {
          paths = cfg.themes.menus;
          pathsToLink = [
            "/share/kando/menu-themes"
          ];
        };
      };

      "kando/sound-themes" = lib.mkIf (cfg.themes.sounds != [ ]) {
        source = pkgs.buildEnv {
          paths = cfg.themes.menus;
          pathsToLink = [
            "/share/kando/sound-themes"
          ];
        };
      };

      "kando/icon-themes" = lib.mkIf (cfg.themes.icons != [ ]) {
        source = pkgs.buildEnv {
          paths = cfg.themes.menus;
          pathsToLink = [
            "/share/kando/icon-themes"
          ];
        };
      };
    };
  };
}
