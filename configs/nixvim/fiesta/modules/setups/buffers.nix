{ config, lib, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.buffers;

  bindingPrefix = "<leader>b";
  bindingPrefix' = k: "${bindingPrefix}${k}";
in
{
  options.nixvimConfigs.fiesta.setups.buffers.enable =
    lib.mkEnableOption "buffers setup";

  config = lib.mkIf cfg.enable {
    plugins.which-key.settings.spec = lib.singleton
      (helpers.listToUnkeyedAttrs [ bindingPrefix ] // { group = "Buffers"; });

    plugins.gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          ignore_whitespace = true;
        };

        on_attach = helpers.mkRaw
          /* lua */ ''
          function(bufnr)
            local gitsigns = require("gitsigns")

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            map("n", "]c", function()
              if vim.wo.diff then
                vim.cmd.normal({"]c", bang=true})
              else
                gitsigns.nav_hunk("next")
              end
            end, { desc = "Go to next diff" })

            map("n", "[c", function()
              if vim.wo.diff then
                vim.cmd.normal({"[c", bang=true})
              else
                gitsigns.nav_hunk("prev")
              end
            end, { desc = "Go to previous diff" })

            map("n", "${bindingPrefix' "s"}", gitsigns.stage_hunk, {
              desc = "Stage hunk under cursor",
            })
            map("n", "${bindingPrefix' "r"}", gitsigns.reset_hunk, {
              desc = "Reset hunk under cursor",
            })

            map("v", "${bindingPrefix' "s"}", function()
              gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = "Stage hunk under selection" })
            map("v", "${bindingPrefix' "r"}", function()
              gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = "Reset hunk under selection" })

            map({'o', 'x'}, 'ih', gitsigns.select_hunk)
          end
        '';
      };
    };

    keymaps = [
      {
        mode = "n";
        key = bindingPrefix' "d";
        action = helpers.mkRaw "vim.cmd.bdelete";
        options.desc = "Delete current buffer";
      }
    ];
  };
}
