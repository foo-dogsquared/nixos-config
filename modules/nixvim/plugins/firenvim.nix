{ config, lib, pkgs, helpers, ... }:

let
  cfg = config.plugins.firenvim;
in
{
  options.plugins.firenvim = {
    enable = lib.mkEnableOption "Firenvim";
    package = helpers.mkPackageOption "firenvim" pkgs.vimPlugins.firenvim;
    extraConfig = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
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
      description = ''
        Extra configuration options for Firenvim.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins = [ cfg.package ];

    globals.firenvim_config = cfg.extraConfig;
  };
}
