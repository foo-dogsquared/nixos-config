{ config, lib, pkgs, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.completion;
in {
  options.nixvimConfigs.fiesta.setups.completion.enable =
    lib.mkEnableOption "debugging setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      plugins.cmp = {
        enable = true;
        autoEnableSources = true;

        settings.mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-u>" = "cmp.mapping.scroll_docs(4)";
          "<C-g>" = "cmp.mapping.close()";
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
        };

        settings.sources =
          [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];
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

    (lib.mkIf nixvimCfg.setups.snippets.enable {
      plugins.cmp.settings = {
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';

        sources = [{ name = "luasnip"; }];
      };

      plugins.cmp_luasnip.enable = true;
    })

    (lib.mkIf nixvimCfg.setups.treesitter.enable {
      plugins.cmp-treesitter.enable = true;
    })
  ]);
}
