{ config, lib, pkgs, ... }:

{
  colorschemes.kanagawa.enable = true;

  clipboard.providers.wl-copy.enable = true;
  clipboard.providers.xclip.enable = true;

  plugins.neorg.enable = true;
  plugins.nvim-autopairs.enable = true;

  extraPlugins = with pkgs; [
    decker
  ];
}
