{ config, lib, pkgs, ... }:

let
  cfg = config.programs.neovide;

  settingsFormat = pkgs.formats.toml { };
in
{
  options.programs.neovide = {
    enable = lib.mkEnableOption "Neovide, a graphical interface for Neovim";

    package = lib.mkPackageOption pkgs "neovide" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        The settings to be generated at
        {file}`$XDG_CONFIG_HOME/neovide/config.toml`.
      '';
      default = { };
      example = {
        maximized = true;

        font = {
          normal = [ "MonoLisa Nerd Font" ];
          size = 18;
          features.MonoLisa = [
            "+ss01"
            "+ss07"
            "+ss11"
            "-calt"
            "+ss09"
            "+ss02"
            "+ss14"
            "+ss16"
            "+ss17"
          ];
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ cfg.package ];
    }

    (lib.mkIf (cfg.settings != { }) {
      xdg.configFile."neovide/config.toml".source =
        settingsFormat.generate "home-manager-neovide-settings" cfg.settings;
    })
  ]);
}
