{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.alacritty;
in
{
  options.modules.alacritty.enable = lib.mkEnableOption "Enable Alacritty config";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ alacritty ];
    xdg.configFile."alacritty" = {
      source = ../config/alacritty/alacritty.yml;
      recursive = true;
    };
  };
}
