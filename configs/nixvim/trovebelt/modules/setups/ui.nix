{ config, lib, ... }:

let
  nixvimCfg = config.nixvimConfigs.trovebelt;
  cfg = nixvimCfg.setups.ui;
in
{
  options.nixvimConfigs.trovebelt.setups.ui.enable =
    lib.mkEnableOption "configuration for UI-related settings and plugins";

  config = lib.mkIf cfg.enable {
    # Set the colorscheme. Take note, we'll set in the default since this NixVim configuration
    colorschemes = lib.mkDefault { gruvbox.enable = true; };

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
      tab = "↦ *";
      trail = "·";
      nbsp = "%";
    };

    # Taste the rainbow delimiters.
    plugins.rainbow-delimiters.enable = nixvimCfg.setups.treesitter.enable;

    # Enable them status bars.
    plugins.lualine = {
      enable = true;
      iconsEnabled = true;
      globalstatus = true;
      alwaysDivideMiddle = true;

      # Disable the section separators.
      sectionSeparators = {
        left = "";
        right = "";
      };

      sections = {
        lualine_a = [ "mode" ];
        lualine_z = [ "location" ];
      };
    };
  };
}
