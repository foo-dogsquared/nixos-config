{ config, lib, ... }:

{
  imports = [ ./modules ];

  config = {
    nixvimConfigs.trovebelt.setups = {
      lsp.enable = true;
      treesitter.enable = true;
      ui.enable = true;
    };

    # Some general settings.
    globals = {
      mapleader = " ";
      maplocalleader = ",";
      syntax = true;
    };

    options = {
      encoding = "utf-8";
      completeopt = [ "menuone" "noselect" ];
      expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
    };
  };
}
