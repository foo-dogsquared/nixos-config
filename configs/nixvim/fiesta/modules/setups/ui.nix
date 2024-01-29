{ config, lib, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.ui;
in
{
  options.nixvimConfigs.fiesta.setups.ui.enable =
    lib.mkEnableOption "configuration for UI-related settings and plugins";

  config = lib.mkIf cfg.enable {
    # Set the colorscheme.
    colorschemes.kanagawa.enable = true;

    # Make it so that terminal GUI colors are au natural.
    options.termguicolors = true;

    # Show locations you're supposed to be copying from the internet (or your
    # own code).
    options.number = true;

    # Make it easy to count.
    options.relativenumber = true;

    # Make it easy to identify your cursor.
    options.cursorline = true;

    # Conceal all of the hidden weapons (or distractions).
    options.conceallevel = 1;

    # Show them hidden suckers.
    options.list = true;
    options.listchars = {
      tab = "↦  ";
      trail = "·";
    };

    # Taste the rainbow delimiters.
    plugins.rainbow-delimiters.enable = true;
  };
}
