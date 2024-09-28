{ config, lib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.networking;

  # This is just referring to the same interface just with alternative names.
  mainEthernetInterfaceNames = [ "eth0" "enp1s0" ];
  internalEthernetInterfaceNames = [ "enp7s0" ];
  inherit (config.state.network) interfaces;
in
{
  options.hosts.plover.services.networking.enable =
    lib.mkEnableOption "preferred networking setup";

  config = lib.mkIf cfg.enable {
    networking = {
      enableIPv6 = true;
      usePredictableInterfaceNames = lib.mkDefault true;
      useNetworkd = true;

      # We're using networkd to configure so we're disabling this
      # service.
      useDHCP = false;
      dhcpcd.enable = false;

      # We'll make use of their timeservers.
      timeServers = lib.mkBefore [
        "ntp1.hetzner.de"
        "ntp2.hetzner.com"
        "ntp3.hetzner.net"
      ];
    };

    # The local DNS resolver. This should be used in conjunction with an
    # authoritative DNS server as a forwarder. Also, it should live in its
    # default address at 127.0.0.53 (as of systemd v252).
    services.resolved = {
      enable = true;
      dnssec = "false";
    };

    # The interface configuration is based from the following discussion:
    # https://discourse.nixos.org/t/nixos-on-hetzner-cloud-servers-ipv6/221/
    systemd.network = {
      enable = true;
      wait-online.ignoredInterfaces = [ "lo" ];

      # For more information, you can look at Hetzner documentation from
      # https://docs.hetzner.com/robot/dedicated-server/ip/additional-ip-adresses/
      networks = {
        "10-wan" = let
          inherit (interfaces) wan;
        in {
          matchConfig.Name = lib.concatStringsSep " " mainEthernetInterfaceNames;

          # Setting up IPv6.
          address = [
            "${wan.ipv4}/32"
            "${wan.ipv6}/64"
          ];
          gateway = [ wan.ipv6Gateway ];

          dns = [
            "185.12.64.1"
            "185.12.64.2"

            "2a01:4ff:ff00::add:2"
            "2a01:4ff:ff00::add:1"
          ]
          ++ lib.optionals hostCfg.services.dns-server.enable [
            wan.ipv4
            wan.ipv6
          ];

          # Setting up some other networking thingy.
          domains = [ config.networking.domain ];

          routes = lib.singleton {
            routeConfig = {
              Gateway = wan.ipv4Gateway;
              GatewayOnLink = true;
            };
          };

          linkConfig.RequiredForOnline = "routable";
        };

        # The interface for our LAN.
        "20-lan" = let
          inherit (interfaces) lan;
        in {
          matchConfig.Name = lib.concatStringsSep " " internalEthernetInterfaceNames;

          # Take note of the private subnets set in your Hetzner Cloud instance
          # (at least for IPv4 addresses)..
          address = [
            "${lan.ipv4}/16"
            "${lan.ipv6}/64"
          ];

          # Using the authoritative DNS server to enable accessing them nice
          # internal services with domain names.
          dns = [
            lan.ipv4
            lan.ipv6
          ];

          # Force our own internal domain to be used in the system.
          domains = [ config.networking.fqdn ];

          # Use the gateway to enable resolution of external domains.
          gateway = [
            lan.ipv4Gateway
            lan.ipv6Gateway
          ];

          networkConfig.IPv6AcceptRA = true;
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };
  };
}
