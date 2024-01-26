{ config, lib, pkgs, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.desktop-utils;
in
{
  options.nixvimConfigs.fiesta.setups.desktop-utils.enable =
    lib.mkEnableOption "desktop utilities to be used for this Neovim setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      clipboard.providers.wl-copy.enable = true;
      clipboard.providers.xclip.enable = true;
    })
  ]);
}
