{ config, lib, pkgs, helpers, hmConfig, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfg.setups.qol;
in
{
  options.nixvimConfigs.fiesta-fds.setups.qol.enable =
    lib.mkEnableOption "quality-of-life features within fiesta-fds";

  config = lib.mkIf cfg.enable {
    nixvimConfigs.fiesta.setups.qol.enable = lib.mkForce false;

    plugins.snacks = {
      enable = lib.mkForce true;
      settings = {
        bigfile.enabled = true;

        indent = {
          enabled = true;
          char = "┊";

          scope.underline = true;
          chunk.enabled = true;
        };

        input.enabled = true;
        notifier.enabled = true;
        git.enabled = true;
        lazygit.enabled = hmConfig.programs.lazygit.enable;
        quickfile.enabled = true;
        scope.enabled = true;
        words.enabled = true;
      };
    };

    keymaps = [
      {
        key = "<leader>gb";
        action = helpers.mkRaw ''function()
          Snacks.git.blame_line()
        end
        '';
        options.desc = "Open blame lines for the current line";
      }
    ] ++ lib.optionals config.plugins.snacks.settings.lazygit.enabled [
      {
        key = "<leader>gg";
        action = helpers.mkRaw ''function()
          Snacks.lazygit()
        end
        '';
        options.desc = "Open lazygit";
      }

      {
        key = "<leader>gf";
        action = helpers.mkRaw ''function()
          Snacks.lazygit.log_file()
        end
        '';
        options.desc = "Open current file history in lazygit";
      }
    ];
  };
}
