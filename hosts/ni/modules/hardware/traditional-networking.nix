{ config, options, lib, pkgs, ... }:

{
  networking = {
    usePredictableInterfaceNames = true;

    useDHCP = false;
    dhcpcd.enable = true;

    interfaces.enp1s0.useDHCP = true;
    interfaces.wlp2s0.useDHCP = true;

    bonds.bond0 = {
      driverOptions = {
        miimon = "100";
        mode = "active-backup";
      };
      interfaces = [ "enp1s0" "wlp2s0" ];
    };
  };
}
