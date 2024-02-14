{ config, lib, pkgs, helpers, ... }:

let
  cfg = config.plugins.smart-splits;
in
{
  options.plugins.smart-splits = {
    enable = lib.mkEnableOption "smart-splits.nvim";

    package = helpers.mkPackageOption "smart-splits.nvim" pkgs.vimPlugins.smart-splits-nvim;

    settings = helpers.mkSettingsOption {
      description = ''
        Configuration to be passed as argument to `setup` function of the
        plugin.
      '';
      example = {
        resize_mode = {
          quit_key = "<ESC>";
          resize_keys = [ "h" "j" "k" "l" ];
          silent = true;
        };
        ignored_events = [ "BufEnter" "WinEnter" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins = [ cfg.package ];

    extraConfigLua = ''
      require('smart-splits').setup(${helpers.toLuaObject cfg.settings})
    '';
  };
}
