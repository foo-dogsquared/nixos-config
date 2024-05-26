{ config, lib, pkgs, helpers, ... }:

let
  cfg = config.plugins.firenvim;
in
{
  options.plugins.firenvim = {
    enable = lib.mkEnableOption "Firenvim";

    package = helpers.mkPluginPackageOption "firenvim" pkgs.vimPlugins.firenvim;

    settings = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      description = ''
        Extra configuration options for Firenvim.
      '';
      example = {
        globalSettings = { alt = "all"; };
        localSettings = {
          "\".*\"" = {
            cmdline = "nvim";
            content = "text";
            priority = 0;
            selector = "textarea";
            takeover = "always";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins = [ cfg.package ];

    globals.firenvim_config = cfg.settings;
  };
}
