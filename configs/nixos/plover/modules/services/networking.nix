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
  options.hosts.plover.services.networking = {
    enable = lib.mkEnableOption "preferred networking setup";

    restrictLocalOnWAN = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Whether to disable local networking on the public-facing network
        interface. The recommended practice for this is to create another
        network interface with the local network.
      '';
    };

    macAddress = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "MAC address of the public-facing network interface";
      example = "00:00:00:00:c3:54:93";
    };
  };

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
          matchConfig = {
            Name = lib.concatStringsSep " " mainEthernetInterfaceNames;
            PermanentMACAddress = cfg.macAddress;
          };

          networkConfig = {
            DHCP = "ipv4";
            LinkLocalAddressing = "ipv6";
            IPv6AcceptRA = true;
          };

          dhcpV4Config = {
            RouteMetric = 100;
            UseMTU = true;
          };

          address = [ "${wan.ipv6}/64" ];
          dns = [
            "2a01:4ff:ff00::add:2"
            "2a01:4ff:ff00::add:1"
          ];

          routes = [
            {
              Gateway = wan.ipv4Gateway;
              GatewayOnLink = true;
            }

            {
              Gateway = wan.ipv6Gateway;
              GatewayOnLink = true;
            }
          ]
            ++ lib.optionals cfg.restrictLocalOnWAN [
              {
                Destination = "176.16.0.0/12";
                Type = "unreachable";
              }

              {
                Destination = "10.0.0.0/8";
                Type = "unreachable";
              }

              {
                Destination = "192.168.0.0/16";
                Type = "unreachable";
              }

              {
                Destination = "fc00::/7";
                Type = "unreachable";
              }
            ];

          linkConfig.RequiredForOnline = "routable";
        };
      };
    };
  };
}
