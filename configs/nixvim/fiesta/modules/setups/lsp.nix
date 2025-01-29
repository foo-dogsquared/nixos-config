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
    keymaps = [{
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

    # Keymaps for moving around in the buffer.
    plugins.lsp.keymaps.lspBuf = {
      K = "hover";
      gD = "references";
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
    };

    # Keymaps for moving around with the doctor.
    plugins.lsp.keymaps.diagnostic = {
      "<leader>j" = "goto_next";
      "<leader>k" = "goto_prev";
    };

    # Make those diagnostics fit the screen, GODDAMNIT!
    plugins.lsp-lines.enable = true;
  };
}
