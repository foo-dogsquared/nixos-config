# It just contains a set of network-related variables mainly used for
# network-related services. Make sure to change this every time you migrate to
# a new server.
let
  inherit (builtins) toString;
in
rec {
  privateIPv6Prefix = "fc00:b0de:5685::";

  # These blocks should be used sparingly with how wide these blocks cover.
  # Plus, they shouldn't be treated as subnets.
  clientNetworks = [
    "172.24.0.0/13"
    "10.128.0.0/9"
    "fd00::/8"
  ];
  serverNetworks = [
    "172.16.0.0/13"
    "10.0.0.0/9"
    "fc00::/8"
  ];

  interfaces =
    let
      ploverInternalNetworkGateway = "172.16.0.1";
      ipv6Gateway = "fe80::1";
    in
    {
      # This is the public-facing interface. Any interface name with a prime
      # symbol means it's a public-facing interface.
      main' = {
        # The gateways for the public addresses are retrieved from the following
        # pages:
        #
        # * https://docs.hetzner.com/cloud/networks/faq/#are-any-ip-addresses-reserved
        # * https://docs.hetzner.com/robot/dedicated-server/ip/additional-ip-adresses/#gateway
        IPv4 = {
          address = "65.109.224.213";
          gateway = "172.31.1.1";
        };
        IPv6 = {
          address = "2a01:4f9:c012:607a::1";
          gateway = ipv6Gateway;
        };
      };

      internal = {
        IPv4 = {
          address = "172.27.0.1";
          gateway = ploverInternalNetworkGateway;
        };
        IPv6 = {
          address = "${privateIPv6Prefix}1";
          gateway = ipv6Gateway;
        };
      };

      wireguard0 = {
        IPv4 = {
          address = "172.28.0.1";
          gateway = ploverInternalNetworkGateway;
        };
        IPv6 = {
          address = "${wireguardIPv6Prefix}1";
          gateway = ipv6Gateway;
        };
      };
    };

  # Wireguard-related things.
  wireguardPort = 51820;

  # This IPv4 network block should have /13 for the Wireguard network.
  wireguardIPv4Prefix = "172.28.0";

  # This IPv6 network prefix should have /64 for the entire Wireguard network.
  wireguardIPv6Prefix = "fd00:ffff::";

  # These are all fixed IP addresses. However, they should be assigned in /16
  # and /64 for IPv4 and IPv6 block respectively.
  wireguardPeers = {
    server = with interfaces.wireguard0; {
      IPv4 = IPv4.address;
      IPv6 = IPv6.address;
    };
    desktop = {
      IPv4 = "${wireguardIPv4Prefix}.2";
      IPv6 = "${wireguardIPv6Prefix}2";
    };
    phone = {
      IPv4 = "${wireguardIPv4Prefix}.3";
      IPv6 = "${wireguardIPv6Prefix}3";
    };
  };

  secondaryNameServers = {
    "ns1.first-ns.de." = {
      IPv4 = [ "213.239.242.238" ];
      IPv6 = [ "2a01:4f8:0:a101::a:1" ];
    };
    "robotns2.second-ns.de." = {
      IPv4 = [ "213.133.105.6" ];
      IPv6 = [ "2a01:4f8:d0a:2004::2" ];
    };
    "robotns3.second-ns.com." = {
      IPv4 = [ "193.47.99.3" ];
      IPv6 = [ "2001:67c:192c::add:a3" ];
    };
  };
}
