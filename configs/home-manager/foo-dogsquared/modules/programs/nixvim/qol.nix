{ config, lib, pkgs, helpers, hmConfig, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfg.setups.qol;

  bindingPrefix = "<leader>g";
  bindingPrefix' = k: "${bindingPrefix}${k}";
in
{
  options.nixvimConfigs.fiesta-fds.setups.qol.enable =
    lib.mkEnableOption "quality-of-life features within fiesta-fds";

  config = lib.mkIf cfg.enable {
    # We're replacing them with snacks.nvim's implementation.
    plugins.mini.enable = lib.mkForce false;
    plugins.indent-blankline.enable = lib.mkForce false;

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

    plugins.which-key.settings.spec = lib.singleton
      (helpers.listToUnkeyedAttrs [ bindingPrefix ] // { group = "Git"; });

    keymaps = [
      {
        options.desc = "Open blame lines for the current line";
        key = bindingPrefix' "b";
        action = helpers.mkRaw ''function()
          Snacks.git.blame_line()
        end
        '';
      }
    ] ++ lib.optionals config.plugins.snacks.settings.lazygit.enabled [
      {
        options.desc = "Open lazygit";
        key = bindingPrefix' "g";
        action = helpers.mkRaw ''function()
          Snacks.lazygit()
        end
        '';
      }

      {
        options.desc = "Open current file history in lazygit";
        key = bindingPrefix' "f";
        action = helpers.mkRaw ''function()
          Snacks.lazygit.log_file()
        end
        '';
      }
    ];
  };
}
