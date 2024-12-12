{ config, lib, helpers, hmConfig, ... }:

let
  inherit (hmConfig.xdg) userDirs;
  telescopeExtensions = config.plugins.telescope.extensions;
in
{
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

  plugins.telescope.extensions.live-grep-args = {
    enable = true;
  };

  plugins.telescope.keymaps = lib.mkMerge [
    (lib.mkIf telescopeExtensions.frecency.enable {
      "<leader>fp" = {
        mode = "n";
        options.desc = "List projects";
        action = helpers.mkRaw "require('telescope').extensions.project.project{}";
      };
    })

    (lib.mkIf telescopeExtensions.live-grep-args.enable {
      "<leader>fG" = {
        mode = "n";
        options.desc = "Live grep (with args) for the whole project";
        action = helpers.mkRaw "require('telescope').extensions.live_grep_args.live_grep_args";
      };
    })
  ];
}
