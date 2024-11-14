{ config, lib, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.snippets;

  luasnipKeymapConfig = {
    mode = [ "i" "s" ];
  };
in
{
  options.nixvimConfigs.fiesta.setups.snippets.enable =
    lib.mkEnableOption "snippets setup";

  config = lib.mkIf cfg.enable {
    # The main star of the show.
    plugins.luasnip.enable = true;
    plugins.luasnip.settings = {
      keep_roots = true;
      link_roots = true;
      link_children = true;
      enable_autosnippets = false;
    };

    # Set up this collection of snippets.
    plugins.friendly-snippets.enable = true;

    # Load all of the custom snippets.
    plugins.luasnip.fromLua = [
      {
        lazyLoad = true;
        paths = ./snippets;
      }
    ];

    # Set up the keymaps ourselves since LuaSnip doesn't provide one as a
    # config option.
    keymaps = [
      (luasnipKeymapConfig // {
        key = "<C-j>";
        options.desc = "Jump to next node";
        action = helpers.mkRaw ''
          function()
            ls = require("luasnip")
            if ls.jumpable(1) then
              ls.jump(1)
            end
          end
        '';
      })

      (luasnipKeymapConfig // {
        key = "<C-k>";
        options.desc = "Jump to previous node";
        action = helpers.mkRaw ''
          function()
            ls = require("luasnip")
            if ls.jumpable(-1) then
              ls.jump(-1)
            end
          end
        '';
      })

      (luasnipKeymapConfig // {
        key = "<C-l>";
        options.desc = "Expand or jump to next node";
        action = helpers.mkRaw ''
          function()
            ls = require("luasnip")
            if ls.expand_or_jumpable() then
              ls.expand_or_jump()
            end
          end
        '';
      })

      (luasnipKeymapConfig // {
        key = "<C-u>";
        options.desc = "Show extra choices";
        action = helpers.mkRaw ''
          function()
            require("luasnip.extras.select_choice")()
          end
        '';
      })
    ];
  };
}
