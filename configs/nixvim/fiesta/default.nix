{ config, lib, pkgs, helpers, ... }:

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

    opts = {
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
        options.desc = "Escape";
      }

      {
        mode = "n";
        key = "<leader>bd";
        action = helpers.mkRaw "vim.cmd.bdelete";
        options.desc = "Delete current buffer";
      }
    ];

    plugins.nvim-autopairs.enable = true;
  };
}
