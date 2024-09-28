{ config, lib, helpers, pkgs, ... }:

let
  cfg = config.plugins.legendary-nvim;

  mkEnableOption' = desc: lib.mkEnableOption desc // { default = true; };
in
{
  options.plugins.legendary-nvim = {
    enable = lib.mkEnableOption "legendary.nvim";

    package = lib.mkPackageOption pkgs [ "vimPlugins" "legendary-nvim" ] { };

    additionalSetup = mkEnableOption' "dependencies for additional features like frecency sorting";

    integrations = {
      nvim-tree.enable =
        mkEnableOption' "integration with nvim-tree (if installed)";
      smart-splits.enable =
        mkEnableOption' "integration with smart-splits.nvim (if installed)";
      diffview.enable =
        mkEnableOption' "integration with diffview (if installed)";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;

        config = lib.mkMerge [
          (lib.mkIf
            (
              config.plugins.nvim-tree.enable && cfg.integrations.nvim-tree.enable
            )
            { extensions.nvim_tree = true; })
          (lib.mkIf
            (
              config.plugins.smart-splits.enable && cfg.integrations.smart-splits.enable
            )
            {
              extensions.smart_splits = {
                directions = [ "h" "j" "k" "l" ];
                mods = { };
              };
            })
          (lib.mkIf
            (
              config.plugins.diffview.enable && cfg.integrations.diffview.enable
            )
            { extensions.diffview = true; })
        ];
      };
      default = { };
      example = { };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins =
      [ cfg.package ]
      ++ lib.optional cfg.additionalSetup pkgs.vimPlugins.sqlite-lua;

    extraPackages = lib.optional cfg.additionalSetup pkgs.sqlite;

    extraConfigLua = ''
      require('legendary').setup(${helpers.toLuaObject cfg.settings})
    '';
  };
}
