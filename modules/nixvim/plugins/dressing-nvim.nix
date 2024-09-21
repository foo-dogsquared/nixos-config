{ config, lib, pkgs, helpers, ... }:

let
  cfg = config.plugins.dressing-nvim;
in
{
  options.plugins.dressing-nvim = {
    enable = lib.mkEnableOption "dressing.nvim configuration";

    package = helpers.mkPluginPackageOption "dressing.nvim" pkgs.vimPlugins.dressing-nvim;

    settings = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      example = {
        input = {
          enabled = true;
          default_prompt = "Input";
          trim_prompt = false;
        };
        select = {
          enabled = true;
          backend = [ "telescope" "fzf_lua" "builtin" "nui" ];
        };
      };
      description = ''
        Settings to be passed as argument to plugin's `setup` method.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins = [ cfg.package ];

    extraConfigLua = ''
      require('dressing').setup(${helpers.toLuaObject cfg.settings})
    '';
  };
}
