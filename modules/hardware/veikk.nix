# Installs the VEIKK Linux driver at https://github.com/jlam55555/veikk-linux-driver.
{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.hardware.veikk;
in {
  options.modules.hardware.veikk = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ pkgs.veikk-linux-driver ];
  };
}
