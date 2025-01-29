{ config, lib, pkgs, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.devenvs;
in {
  options.nixvimConfigs.fiesta.setups.devenvs.enable =
    lib.mkEnableOption "integration for typical devenvs";

  config = lib.mkIf cfg.enable {
    plugins.direnv.enable = true;
    plugins.nvim-remote-containers.enable = true;
  };
}
