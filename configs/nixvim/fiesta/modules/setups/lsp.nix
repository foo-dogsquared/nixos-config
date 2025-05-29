{ config, lib, helpers, ... }:

let
  nixvimConfig = config.nixvimConfigs.fiesta;
  cfg = nixvimConfig.setups.lsp;
in {
  options.nixvimConfigs.fiesta.setups.lsp.enable = lib.mkEnableOption null // {
    description = ''
      Whether to enable LSP setup. Take note you'll have to enable and
      configure individual language servers yourself since the resulting
      NixVim config can be pretty heavy.
    '';
  };

  config = lib.mkIf cfg.enable {
    keymaps = lib.optionals config.plugins.lsp.inlayHints [{
      mode = [ "n" ];
      key = "<leader>Li";
      options.desc = "Toggle inlay hints";
      action = helpers.mkRaw ''
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end
      '';
    }];

    plugins.lsp = {
      enable = true;
      inlayHints = true;
    };

    lsp.keymaps = [
      {
        options.desc = "Go to next diagnostic";
        key = "gj";
        action = helpers.mkRaw
          /* lua */ ''
            function()
              vim.diagnostic.jump({ count = -1, float = true })
            end
          '';
      }

      {
        options.desc = "Go to previous diagnostic";
        key = "gk";
        action = helpers.mkRaw
          /* lua */ ''
            function()
              vim.diagnostic.jump({ count = 1, float = true })
            end
          '';
      }

      {
        options.desc = "Hover";
        key = "K";
        lspBufAction = "hover";
      }

      {
        options.desc = "Go to references";
        key = "gD";
        lspBufAction = "references";
      }

      {
        options.desc = "Go to definition";
        key = "gd";
        lspBufAction = "definition";
      }

      {
        options.desc = "Go to implementation";
        key = "gi";
        lspBufAction = "implementation";
      }

      {
        options.desc = "Go to type definition";
        key = "gt";
        lspBufAction = "type_definition";
      }
    ];

    # Make those diagnostics fit the screen, GODDAMNIT!
    plugins.lsp-lines.enable = true;
  };
}
