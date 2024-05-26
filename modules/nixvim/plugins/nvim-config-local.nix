{ config, lib, pkgs, helpers, ... }:

let
  cfg = config.plugins.nvim-config-local;
in
{
  options.plugins.nvim-config-local =
    helpers.neovim-plugin.extraOptionsOptions // {
      enable = lib.mkEnableOption "nvim-config-local";

      package = helpers.mkPluginPackageOption "nvim-config-local" pkgs.vimPlugins.nvim-config-local;

      configFiles = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ".nvim.lua" ".nvimrc" ".exrc" ];
        example = [ "config/nvim.lua" ];
        description = ''
          A list of patterns to load (includes Lua configurations).
        '';
      };

      autocommandsCreate = helpers.defaultNullOpts.mkBool true "Create autocommands for sourcing local files.";
      commandsCreate = helpers.defaultNullOpts.mkBool true "Create user commands for nvim-config-local.";
      lookupParents = helpers.defaultNullOpts.mkBool false "Enable lookup in parent directories when sourcing local configs.";
    };

  config =
    let
      setupOptions = {
        config_files = cfg.configFiles;
        autocommands_create = cfg.autocommandsCreate;
        commands_create = cfg.commandsCreate;
        lookup_parents = cfg.lookupParents;
      } // cfg.extraOptions;
    in
    lib.mkIf cfg.enable {
      extraPlugins = [ cfg.package ];

      extraConfigLua = ''
        require("config-local").setup(${helpers.toLuaConfig setupOptions})
      '';
    };
}
