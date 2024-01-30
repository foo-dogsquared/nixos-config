{ config, lib, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.fuzzy-finder;
in
{
  options.nixvimConfigs.fiesta.setups.fuzzy-finder.enable =
    lib.mkEnableOption "fuzzy finder setup";

  config = lib.mkIf cfg.enable {
    plugins.telescope.enable = true;

    # Configure all of the keymaps.
    keymaps =
      let
        bindingPrefix = "<leader>f";
        mkTelescopeKeymap = acc: binding: settings:
          acc ++ [
            (lib.mergeAttrs {
              mode = "n";
              key = "${bindingPrefix}${binding}";
            } settings)
          ];
      in
      lib.foldlAttrs mkTelescopeKeymap [ ] ({
        "A" = {
          options.desc = "Resume from last use";
          action = "require('telescope.builtin').resume";
          lua = true;
        };
        "b" = {
          options.desc = "List buffers";
          action = "require('telescope.builtin').buffers";
          lua = true;
        };
        "f" = {
          options.desc = "Find files";
          action = ''
            function()
              require('telescope.builtin').find_files { hidden = true }
            end
          '';
          lua = true;
        };
        "F" = {
          options.desc = "Find files in current directory";
          action = ''
            function()
              require('telescope.builtin').find_files {
                cwd = require('telescope.utils').buffer_dir(),
                hidden = true,
              }
            end
          '';
          lua = true;
        };
        "g" = {
          options.desc = "Find files tracked by Git";
          action = "require('telescope.builtin').git_files";
          lua = true;
        };
        "G" = {
          options.desc = "Live grep for the whole project";
          action = "require('telescope.builtin').live_grep";
          lua = true;
        };
        "h" = {
          options.desc = "Find section from help tags";
          action = "require('telescope.builtin').help_tags";
          lua = true;
        };
        "m" = {
          options.desc = "Find manpage entries";
          action = "require('telescope.builtin').man_pages";
          lua = true;
        };
      }
      // lib.optionalAttrs nixvimCfg.setups.treesitter.enable {
        "t" = {
          options.desc = "List symbols from treesitter queries";
          action = "require('telescope.builtin').treesitter";
          lua = true;
        };
      });
  };
}

