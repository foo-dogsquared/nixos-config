{ config, lib, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.ui;
in {
  options.nixvimConfigs.fiesta.setups.ui.enable =
    lib.mkEnableOption "configuration for UI-related settings and plugins";

  config = lib.mkIf cfg.enable {
    # Set the colorscheme. Take note, we'll set in the default since this NixVim configuration
    colorschemes = lib.mkDefault { kanagawa.enable = true; };

    # Make it so that terminal GUI colors are au natural.
    opts.termguicolors = true;

    # Show locations you're supposed to be copying from the internet (or your
    # own code).
    opts.number = true;

    # Make it easy to count.
    opts.relativenumber = true;

    # Make it easy to identify your cursor.
    opts.cursorline = true;

    # Conceal all of the hidden weapons (or distractions).
    opts.conceallevel = 1;

    # Show them hidden suckers.
    opts.list = true;
    opts.listchars = {
      tab = "↦ ";
      trail = "·";
      nbsp = "%";
    };

    # My elderly forgot-how-to-do-this assistant.
    plugins.which-key.enable = true;

    # Taste the rainbow delimiters.
    plugins.rainbow-delimiters.enable = nixvimCfg.setups.treesitter.enable;

    # Taste the indent guides (with rainbow delimiters).
    plugins.indent-blankline = {
      enable = true;
      settings = {
        indent = { char = "┊"; };
        scope.char = "┃";
      };
    };

    # mini.plugins
    plugins.mini = {
      enable = lib.mkDefault true;

      mockDevIcons = true;
      modules.icons = { };
    };

    # Enable them status bars.
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          icons_enabled = true;
          globalstatus = true;
          always_divide_middle = true;
        };

        # Disable the section separators.
        section_separators = {
          left = "";
          right = "";
        };

        sections = {
          lualine_a = [ "mode" ];
          lualine_c = [
            "filename"

            {
              newfile_status = true;
              shorting_target = 10;
              path = 1;
            }
          ];
          lualine_z = [ "location" ];
        };
      };
    };
  };
}
