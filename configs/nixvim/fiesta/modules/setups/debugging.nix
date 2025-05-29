{ config, lib, pkgs, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.debugging;
  bindingPrefix = "<Leader>d";
in {
  options.nixvimConfigs.fiesta.setups.debugging.enable =
    lib.mkEnableOption "debugging setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable {
    plugins.dap.enable = true;
    plugins.dap-ui.enable = true;
    plugins.dap-virtual-text.enable = true;
    plugins.debugprint = {
      enable = true;
      settings = {
        variable_below_alwaysprompt = null;
        variable_above_alwaysprompt = null;
      };
    };

    plugins.which-key.settings.spec = [
      (helpers.listToUnkeyedAttrs [ bindingPrefix ] // { group = "Debug"; })
      (helpers.listToUnkeyedAttrs [ "${bindingPrefix}D" ] // { group = "Within session"; })
    ];

    keymaps = let
      mkDAPBinding = binding: settings:
        {
          mode = "n";
          key = "${bindingPrefix}${binding}";
        } // settings;
    in lib.mapAttrsToList mkDAPBinding {
      "b" = {
        options.desc = "Toggle breakpoint";
        action = helpers.mkRaw "require('dap').toggle_breakpoint";
      };

      "Bb" = {
        options.desc = "Set breakpoint";
        action = helpers.mkRaw "require('dap').set_breakpoint";
      };

      "Bp" = {
        options.desc = "Set breakpoint with log message";
        action = helpers.mkRaw /* lua */ ''
          function()
            require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
          end
        '';
      };

      "n" = {
        options.desc = "Continue";
        action = helpers.mkRaw "require('dap').continue";
      };

      # You know, like a comma is supposed to do. I got nothing on this one
      # but this is the best choice for now.
      "," = {
        options.desc = "Pause";
        action = helpers.mkRaw "require('dap').pause";
      };

      "d" = {
        options.desc = "Terminate";
        action = helpers.mkRaw "require('dap').terminate";
      };

      "Dl" = {
        options.desc = "Step over";
        action = helpers.mkRaw "require('dap').step_over";
      };

      "Dj" = {
        options.desc = "Step into";
        action = helpers.mkRaw "require('dap').step_into";
      };

      "DJ" = {
        options.desc = "Go up";
        action = helpers.mkRaw "require('dap').up";
      };

      "Dk" = {
        options.desc = "Step out";
        action = helpers.mkRaw "require('dap').step_out";
      };

      "DK" = {
        options.desc = "Go down";
        action = helpers.mkRaw "require('dap').down";
      };

      "R" = {
        options.desc = "Restart session";
        action = helpers.mkRaw "require('dap').restart";
      };

      "r" = {
        options.desc = "Toggle REPL";
        action = helpers.mkRaw "require('dap').repl.toggle";
      };

      "." = {
        options.desc = "Run last configuration";
        action = helpers.mkRaw "require('dap').run_last";
      };

      "Dh" = {
        options.desc = "View the value under the cursor";
        action = helpers.mkRaw "require('dap.ui.widgets').hover";
        mode = [ "n" "v" ];
      };

      "Dp" = {
        options.desc = "See value in preview window";
        action = helpers.mkRaw "require('dap.ui.widgets').preview";
        mode = [ "n" "v" ];
      };
    } ++ [
      {
        key = "<F5>";
        options.desc = "Continue";
        action = helpers.mkRaw "require('dap').continue";
      }

      {
        key = "<F9>";
        options.desc = "Toggle breakpoint";
        action = helpers.mkRaw "require('dap').toggle_breakpoint";
      }

      {
        key = "<F10>";
        options.desc = "Step over";
        action = helpers.mkRaw "require('dap').step_over";
      }

      {
        key = "<F11>";
        options.desc = "Step into";
        action = helpers.mkRaw "require('dap').step_into";
      }

      {
        key = "<F12>";
        options.desc = "Step out";
        action = helpers.mkRaw "require('dap').step_out";
      }
    ];
  };
}
