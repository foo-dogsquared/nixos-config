{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sesh;

  settingsFormat = pkgs.formats.toml { };
in
{
  # TODO: Add tmux integrations.
  options.programs.sesh = {
    enable = lib.mkEnableOption "sesh, a smart session manager";

    package = lib.mkPackageOption pkgs "sesh" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Program settings to be generated at
        {file}`$XDG_CONFIG_HOME/sesh/sesh.toml`.
      '';
      example = lib.literalExpression ''
        {
          default_session = {
            startup_command = "nvim -c ':Telescope find_files'";
            preview_command = "eza --all --git --icons --color=always {}";
          };

          session = [
            {
              name = "Downloads";
              path = config.xdg.userDirs.downloads;
              startup_command = "ls";
            }

            {
              name = "tmux config";
              path = "~/c/dotfiles/tmux_config";
              startup_command = "nvim tmux.conf";
              preview_command = "bat --color=always ~/c/dotfiles/.config/tmux/tmux.conf";
            }
          ];
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      warnings = lib.optionals (!config.programs.zoxide.enable || !config.programs.fzf.enable) ''
        You haven't enabled Zoxide nor fzf which is recommended to use alongside sesh.
      '';

      home.packages = [ cfg.package ];
    }

    (lib.mkIf (cfg.settings != { }) {
      xdg.configFile."sesh/sesh.toml".source =
        settingsFormat.generate "sesh-user-settings" cfg.settings;
    })
  ]);
}
