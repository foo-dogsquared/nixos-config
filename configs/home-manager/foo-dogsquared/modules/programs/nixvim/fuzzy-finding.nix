{ config, lib, helpers, hmConfig, ... }:

let
  inherit (hmConfig.xdg) userDirs;
  nixvimCfg = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfg.setups.fuzzy-finding;
  telescopeExtensions = config.plugins.telescope.extensions;
in {
  options.nixvimConfigs.fiesta-fds.setups.fuzzy-finding.enable =
    lib.mkEnableOption "fuzzy finding setup within fiesta-fds";

  config = lib.mkIf cfg.enable {
    plugins.telescope.extensions.frecency = {
      enable = true;
      settings = {
        show_scores = true;
        show_unindexed = true;
        workspaces = {
          writings = "${userDirs.documents}/Writings";
          packages = "${userDirs.extraConfig.XDG_PROJECTS_DIR}/packages";
          software = "${userDirs.extraConfig.XDG_PROJECTS_DIR}/software";
        };
      };
    };

    plugins.telescope.extensions.live-grep-args = { enable = true; };

    keymaps = lib.optionals telescopeExtensions.live-grep-args.enable
      (lib.singleton {
        mode = "n";
        key = "<leader>fG";
        options.desc = "Live grep (with args) for the whole project";
        action = helpers.mkRaw
          "require('telescope').extensions.live_grep_args.live_grep_args";
      });
  };
}
