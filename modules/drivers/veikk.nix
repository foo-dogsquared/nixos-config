# Installs the VEIKK Linux driver at https://github.com/jlam55555/veikk-linux-driver.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.drivers.veikk = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.drivers.veikk.enable {
    boot.extraModulePackages = [ pkgs.veikk-linux-driver ];
  };
}
