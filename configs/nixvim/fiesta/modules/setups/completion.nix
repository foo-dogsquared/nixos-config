{ config, lib, pkgs, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.completion;
in
{
  options.nixvimConfigs.fiesta.setups.completion.enable =
    lib.mkEnableOption "debugging setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      plugins.nvim-cmp = {
        enable = true;
        autoEnableSources = true;

        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-u>" = "cmp.mapping.scroll_docs(4)";
          "<C-g>" = "cmp.mapping.close()";
          "<Tab>" = {
            action = "cmp.mapping.select_next_item()";
            modes = [ "i" "s" ];
          };
          "<S-Tab>" = {
            action = "cmp.mapping.select_prev_item()";
            modes = [ "i" "s" ];
          };
        };

        sources = [
          {
            name = "nvim_lsp";
            groupIndex = 1;
          }

          (lib.mkIf nixvimCfg.setups.snippets.enable {
            name = "luasnip";
            groupIndex = 2;
          })

          { name = "buffer"; }

          {
            name = "path";
            groupIndex = 3;
          }
        ];
      };

      # All of the typical completion sources I would need.
      plugins.cmp-buffer.enable = true;
      plugins.cmp-path.enable = true;
      plugins.cmp-vim-lsp.enable = true;
      plugins.cmp-nvim-lua.enable = true;
    }

    (lib.mkIf nixvimCfg.setups.debugging.enable {
      plugins.cmp-dap.enable = true;
    })

    (lib.mkIf nixvimCfg.setups.treesitter.enable {
      plugins.cmp-treesitter.enable = true;
    })

    (lib.mkIf nixvimCfg.setups.snippets.enable {
      plugins.cmp_luasnip.enable = true;
    })
  ]);
}
