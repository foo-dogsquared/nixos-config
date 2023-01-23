# It just contains a set of network-related variables mainly used for
# network-related services. Make sure to change this every time you migrate to
# a new server.
let
  inherit (builtins) toString;
in
rec {
  privateIPv6Prefix = "fdee:b0de:5685";
  interfaces = {
    # This is the public-facing interface. Any interface name with a prime
    # symbol means it's a public-facing interface.
    main' = {
      IPv4 = "95.217.212.19";
      IPv6 = "2a01:4f9:c011:a448::1";
    };

    # /16 block for IPv4, /64 for IPv6.
    main = {
      IPv4 = "172.25.0.1";
      IPv6 = "${privateIPv6Prefix}:1::";
    };

    # /16 block for IPv4, /64 for IPv6.
    internal = {
      IPv4 = "172.24.0.1";
      IPv6 = "${privateIPv6Prefix}:2::";
    };

    # /16 BLOCK for IPv4, /64 for IPv6.
    wireguard0 = {
      IPv4 = "10.210.0.1";
      IPv6 = "${privateIPv6Prefix}:12ae::";
    };
  };

  # The private network for this host.
  preferredInternalTLD = "internal";

  # Wireguard-related things.
  wireguardPort = 51820;
  wireguardIPHostPart = "10.210.0";
  wireguardIPv6Prefix = interfaces.wireguard0.IPv6;

  # These are all fixed IP addresses. They should be /32 IPv4 block and /128
  # IPv6 block.
  wireguardPeers = {
    server = with interfaces.wireguard0; { inherit IPv4 IPv6; };
    desktop = {
      IPv4 = "${wireguardIPHostPart}.2";
      IPv6 = "${wireguardIPv6Prefix}:12ae::2";
    };
    phone = {
      IPv4 = "${wireguardIPHostPart}.3";
      IPv6 = "${wireguardIPv6Prefix}:12ae::3";
    };
  };
}
