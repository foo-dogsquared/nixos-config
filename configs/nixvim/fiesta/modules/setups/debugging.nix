{ config, lib, pkgs, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.debugging;
in
{
  options.nixvimConfigs.fiesta.setups.debugging.enable =
    lib.mkEnableOption "debugging setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable {
    plugins.dap.enable = true;
    plugins.dap.extensions.dap-ui.enable = true;
    plugins.dap.extensions.dap-virtual-text.enable = true;
    plugins.debugprint = {
      enable = true;
      ignoreTreesitter = false;
    };
  };
}
