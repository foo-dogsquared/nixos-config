{ config, options, lib, pkgs, ... }:

{
  networking = {
    usePredictableInterfaceNames = true;

    useDHCP = false;
    dhcpcd.enable = true;

    interfaces.enp1s0.useDHCP = true;
    interfaces.wlp2s0.useDHCP = true;

    # The simpler WiFi manager.
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true;
          UseDefaultInterface = true;
          ControlPortOverNL80211 = true;
        };

        Network = {
          AutoConnect = true;
          NameResolvingService = "systemd";
        };
      };
    };

    # Set the NetworkManager backend to iwd for workflows that use it.
    networkmanager.wifi.backend = "iwd";

    bonds.bond0 = {
      driverOptions = {
        miimon = "100";
        mode = "active-backup";
      };
      interfaces = [ "enp1s0" "wlp2s0" ];
    };
  };
}
