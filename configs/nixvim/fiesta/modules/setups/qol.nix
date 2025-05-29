{ config, lib, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.devenvs;
in {
  options.nixvimConfigs.fiesta.setups.qol.enable =
    lib.mkEnableOption "quality-of-life improvements";

  config = lib.mkIf cfg.enable {
    plugins.mini = {
      enable = true;
      modules = {
        ai = {
          n_lines = 50;
          search_method = "cover_or_next";
        };
        surround = { };
        align = { };
        bracketed = { };
      };
    };

    plugins.conjure.enable = true;

    plugins.parinfer-rust.enable = true;

    plugins.oil = {
      enable = true;
      settings = {
        columns = [ "icon" "permissions" ];
        default_file_explorer = true;
        view_options.show_hidden = true;
        keymaps = {
          "<C-=>" = "actions.open_terminal";
        };
      };
    };

    keymaps =
      lib.optionals config.plugins.oil.enable [
        {
          key = "-";
          options.desc = "Open Oil file explorer";
          action = "<cmd>Oil<CR>";
        }

        {
          key = "<C-->";
          options.desc = "Open Oil file explorer in root directory";
          action = helpers.mkRaw ''
            function()
              require("oil").open(vim.fn.getcwd())
            end
          '';
        }
      ];
  };
}
