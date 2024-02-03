{ config, lib, pkgs, ... }:

{
  imports = [ ./modules ];

  config = {
    nixvimConfigs.fiesta.setups = {
      snippets.enable = true;
      ui.enable = true;
      completion.enable = true;
      treesitter.enable = true;
      lsp.enable = true;
      fuzzy-finder.enable = true;
      debugging.enable = true;
      desktop-utils.enable = true;
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

    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
      }

      {
        mode = "n";
        key = "<leader>bd";
        action = "vim.cmd.bdelete";
        lua = true;
      }
    ];

    plugins.nvim-autopairs.enable = true;
  };
}
