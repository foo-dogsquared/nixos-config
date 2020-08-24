{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.themes;
in
{
  imports = [
    ./fair-and-square
  ];

  options.modules.themes = {
    name = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    version = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    path = mkOption {
      type = with types; nullOr path;
      default = null;
    };

    wallpaper = mkOption {
      type = with types; nullOr path;
      default = if cfg.path != null
                then "${cfg.path}/config/wallpaper"
        else null;
    };
  };

  config = mkIf (cfg.path != null && builtins.pathExists cfg.wallpaper) {
    my.home.home.file.".background-image".source = cfg.wallpaper;
  };
}
