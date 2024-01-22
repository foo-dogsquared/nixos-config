{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.networking;
in
{
  options.hosts.ni.networking = {
    enable = lib.mkEnableOption "networking setup";
    setup = lib.mkOption {
      type = lib.types.enum [ "networkd" "networkmanager" ];
      description = ''
        Indicates the component of the network setup. In practice, you'll most
        likely just use NetworkManager since it is what is being supported by
        most desktop setups such as GNOME.

        ::: {.warning}
        Using systemd-networkd setup is considered experimental. Use at your own
        risk.
        :::
      '';
      default = "networkmanager";
      example = "networkd";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Set your time zone.
      time.timeZone = "Asia/Manila";

      # Doxxing myself.
      location = {
        latitude = 15.0;
        longitude = 121.0;
      };

      # Add these timeservers.
      networking.timeServers = lib.mkBefore [
        "ntp.nict.jp"
        "time.nist.gov"
        "time.facebook.com"
      ];

      # Put on your cloak, kid.
      suites.vpn.personal.enable = true;

      # We'll go with a software firewall. We're mostly configuring it as if we're
      # using a server even though the chances of that is pretty slim.
      networking.nftables.enable = true;
      networking.firewall.enable = true;

      # Just supporting local systems, businesses, and business systems.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      # Set resolved for DNS resolutions.
      services.resolved = {
        enable = true;
        llmnr = "true";
        domains = [
          "~plover.foodogsquared.one"
          "~0.27.172.in-addr.arpa"
          "~0.28.172.in-addr.arpa"
        ];
      };
    }

    (lib.mkIf (cfg.setup == "networkd") {
      networking = {
        usePredictableInterfaceNames = true;
        useNetworkd = true;

        # We're using networkd to configure so we're disabling this
        # service.
        useDHCP = false;
        dhcpcd.enable = false;
      };

      # Setting up our network manager of choice.
      systemd.network.enable = true;

      # Setting up the bond devices.
      systemd.network.networks."40-bond1-dev1" = {
        matchConfig.Name = "enp1s0";
        networkConfig.Bond = "bond1";
      };

      systemd.network.networks."40-bond1-dev2" = {
        matchConfig.Name = "wlp2s0";
        networkConfig = {
          Bond = "bond1";
          IgnoreCarrierLoss = "15";
        };
      };

      # Creating the ethernet-wireless-network bond.
      systemd.network.netdevs."40-bond1".netdevConfig = {
        Name = "bond1";
        Kind = "bond";
      };
      systemd.network.networks."40-bond1" = {
        matchConfig.Name = "bond1";
        networkConfig.DHCP = "yes";
      };
    })

    (lib.mkIf (cfg.setup == "networkmanager") {
      networking.usePredictableInterfaceNames = true;

      # Enable and configure NetworkManager.
      networking.networkmanager = lib.mkMerge [
        {
          enable = true;
          dhcp = lib.mkIf (config.networking.dhcpcd.enable) "dhcpcd";
        }

        (lib.mkIf config.services.resolved.enable {
          dns = "systemd-resolved";
        })
      ];

      # We'll configure individual network interfaces to use DHCP since it can
      # fail wait-online-interface.service.
      networking.useDHCP = lib.mkDefault true;

      # Configure the networking bonds.
      networking.bonds.bond0 = {
        driverOptions = {
          miimon = "100";
          mode = "active-backup";
        };
        interfaces = [ "enp1s0" "wlp2s0" ];
      };
    })
  ]);
}
