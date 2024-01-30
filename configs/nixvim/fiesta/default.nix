{ config, lib, pkgs, ... }:

{
  imports = [ ./modules ];

  config = {
    nixvimConfigs.fiesta.setups = {
      snippets.enable = true;
      ui.enable = true;
      completion.enable = true;
      treesitter.enable = true;
      fuzzy-finder.enable = true;
      debugging.enable = true;
      desktop-utils.enable = true;
      note-taking.enable = true;
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
    };

    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
      }
    ];

    plugins.nvim-autopairs.enable = true;
    extraPlugins = with pkgs; [
      decker
    ];
  };
}
