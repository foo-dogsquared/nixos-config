{ config, lib, pkgs, hmConfig, ... }:

let
  userConfig = hmConfig.users.foo-dogsquared;
  nixvimCfg = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfg.setups.misc;
in {
  options.nixvimConfigs.fiesta-fds.setups.misc.enable =
    lib.mkEnableOption "miscellanea plugins";

  config = lib.mkIf cfg.enable {
    extraPlugins = lib.map (path:
      pkgs.runCommand "vim-plugin-bare" { } ''
        mkdir -p "$out"
        cp -r ${path}/* "$out"
      '') (with pkgs; [
        "${decker}/share/vim-plugins/decker"
        "${fzf}/share/vim-plugins/fzf"
      ]);

    # Light your browser on fire, bebe.
    plugins.firenvim = {
      enable = userConfig.programs.browsers.plugins.firenvim.enable;
      settings = {
        localSettings.".*" = {
          selector = "textarea";
          content = "text";
        };
      };
    };

    plugins.legendary-nvim = {
      enable = true;
      integrations.smart-splits.enable = true;
    };

    # Make it work.
    plugins.smart-splits.enable = true;

    # Project-specific Neovim configurations. Fancy.
    globals.exrc = true;
  };
}
