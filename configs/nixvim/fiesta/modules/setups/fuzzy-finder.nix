{ config, lib, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.fuzzy-finder;
in {
  options.nixvimConfigs.fiesta.setups.fuzzy-finder.enable =
    lib.mkEnableOption "fuzzy finder setup";

  config = lib.mkIf cfg.enable {
    plugins.telescope.enable = true;

    plugins.project-nvim = {
      enable = lib.mkDefault true;
      enableTelescope = true;
    };

    # Configure all of the keymaps.
    keymaps = let
      bindingPrefix = "<leader>f";
      mkTelescopeKeymap = binding: settings:
        lib.mergeAttrs {
          mode = "n";
          key = "${bindingPrefix}${binding}";
        } settings;
    in lib.mapAttrsToList mkTelescopeKeymap ({
      "A" = {
        options.desc = "Resume from last use";
        action = helpers.mkRaw "require('telescope.builtin').resume";
      };
      "b" = {
        options.desc = "List buffers";
        action = helpers.mkRaw "require('telescope.builtin').buffers";
      };
      "f" = {
        options.desc = "Find files";
        action = helpers.mkRaw ''
          function()
            require('telescope.builtin').find_files { hidden = true }
          end
        '';
      };
      "F" = {
        options.desc = "Find files in current directory";
        action = helpers.mkRaw ''
          function()
            require('telescope.builtin').find_files {
              cwd = require('telescope.utils').buffer_dir(),
              hidden = true,
            }
          end
        '';
      };
      "v" = {
        options.desc = "Find files tracked by Git";
        action = helpers.mkRaw "require('telescope.builtin').git_files";
      };
      "g" = {
        options.desc = "Live grep for the whole project";
        action = helpers.mkRaw "require('telescope.builtin').live_grep";
      };
      "h" = {
        options.desc = "Find section from help tags";
        action = helpers.mkRaw "require('telescope.builtin').help_tags";
      };
      "m" = {
        options.desc = "Find manpage entries";
        action = helpers.mkRaw "require('telescope.builtin').man_pages";
      };
    } // lib.optionalAttrs nixvimCfg.setups.treesitter.enable {
      "t" = {
        options.desc = "List symbols from treesitter queries";
        action = helpers.mkRaw "require('telescope.builtin').treesitter";
      };
    });
  };
}

