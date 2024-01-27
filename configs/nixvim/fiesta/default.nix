{ config, lib, pkgs, ... }:

{
  colorschemes.kanagawa.enable = true;
  imports = [ ./modules ];

  nixvimConfigs.fiesta.setups = {
    treesitter.enable = true;
    debugging.enable = true;
    desktop-utils.enable = true;
  };

  plugins.neorg.enable = true;
  plugins.nvim-autopairs.enable = true;

  extraPlugins = with pkgs; [
    decker
  ];
}
