{ config, lib, pkgs, ... }:

{
  imports = [ ./modules ];

  nixvimConfigs.fiesta.setups = {
    snippets.enable = true;
    completion.enable = true;
    treesitter.enable = true;
    debugging.enable = true;
    desktop-utils.enable = true;
    ui.enable = true;
  };

  plugins.neorg.enable = true;
  plugins.nvim-autopairs.enable = true;

  extraPlugins = with pkgs; [
    decker
  ];
}
