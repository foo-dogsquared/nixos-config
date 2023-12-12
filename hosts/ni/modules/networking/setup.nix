{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.networking.setup;
in
{
  options.hosts.ni.networking.setup = lib.mkOption {
    type = lib.types.enum [ "networkd" "networkmanager" ];
    default = "networkmanager";
    description = ''
      Indicates the component of the network setup. In practice, you'll most
      likely just use NetworkManager since it is what is being supported by
      most desktop setups such as GNOME.

      ::: {.warning}
      Using systemd-networkd setup is considered experimental. Use at your own
      risk.
      :::
    '';
    example = "networkd";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.setup == "networkd") {
      networking = {
        usePredictableInterfaceNames = true;
        useNetworkd = true;

        # We're using networkd to configure so we're disabling this
        # service.
        useDHCP = false;
        dhcpcd.enable = false;
      };

      # Enable systemd-resolved. This is mostly setup by `systemd.network.enable`
      # by we're being explicit just to be safe.
      services.resolved = {
        enable = true;
        llmnr = "true";
      };

      # Combining my ethernet and wireless network interfaces.
      systemd.network.enable = true;

      # Setting up the bond devices.
      systemd.networks."40-bond1-dev1" = {
        matchConfig.Name = "enp1s0";
        networkConfig.Bond = "bond1";
      };

      systemd.networks."40-bond1-dev2" = {
        matchConfig.Name = "wlp2s0";
        networkConfig = {
          Bond = "bond1";
          IgnoreCarrierLoss = "15";
        };
      };

      # Creating the ethernet-wireless-network bond.
      systemd.netdevs."40-bond1".netdevConfig = {
        Name = "bond1";
        Kind = "bond";
      };
      systemd.networks."40-bond1" = {
        matchConfig.Name = "bond1";
        networkConfig.DHCP = "yes";
      };
    })

    (lib.mkIf (cfg.setup == "networkmanager") {
      networking.usePredictableInterfaceNames = true;

      # Enable and configure NetworkManager.
      networking.networkmanager = {
        enable = true;
        dhcp = lib.mkIf (config.networking.dhcpcd.enable) "dhcpcd";
      };

      # We'll configure individual network interfaces to use DHCP since it can
      # fail wait-online-interface.service.
      networking.useDHCP = false;
      networking.dhcpcd.enable = true;
      networking.interfaces.enp1s0.useDHCP = true;
      networking.interfaces.wlp2s0.useDHCP = true;

      # Configure the networking bonds.
      networking.bonds.bond0 = {
        driverOptions = {
          miimon = "100";
          mode = "active-backup";
        };
        interfaces = [ "enp1s0" "wlp2s0" ];
      };
    })
  ];
}
