{ config, lib, pkgs, helpers, ... }:

let cfg = config.plugins.nvim-config-local;
in {
  options.plugins.nvim-config-local = {
    enable = lib.mkEnableOption "nvim-config-local";

    package = lib.mkPackageOption pkgs [ "vimPlugins" "nvim-config-local" ] { };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          config_files = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ ".nvim.lua" ".nvimrc" ".exrc" ];
            example = [ "config/nvim.lua" ];
            description = ''
              A list of patterns to load (includes Lua configurations).
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins = [ cfg.package ];

    extraConfigLua = ''
      require("config-local").setup(${helpers.toLuaConfig cfg.settings})
    '';
  };
}
