# It just contains a set of network-related variables mainly used for
# network-related services. Make sure to change this every time you migrate to
# a new server.
let
  inherit (builtins) toString;
in
rec {
  publicIP = "95.217.212.19";
  publicIPPrefixLength = 32;
  publicIP' = "${publicIP}/${toString publicIPPrefixLength}";

  publicIPv6 = "2a01:4f9:c011:a448::";
  publicIPv6PrefixLength = 64;
  publicIPv6' = "${publicIPv6}/${toString publicIPv6PrefixLength}";

  # The private network for this host.
  privateNetworkGatewayIP = "172.16.0.1/32";
  preferredInternalTLD = "internal";

  privateIP  = "172.23.0.2";
  privateIPPrefixLength = 16;
  privateIP' = "${privateIPv6}/${toString privateIPv6PrefixLength}";

  # The IPv6 subnet for this host.
  privateIPv6 = "fdee:b0de:5685:a4b3::";
  privateIPv6PrefixLength = 64;
  privateIPv6' = "${privateIPv6}/${toString privateIPv6PrefixLength}";

  # Wireguard-related things.
  wireguardPort = 51820;
  wireguardIPHostPart = "172.23.152";
  wireguardIPHostCreate = interfacePart: "${wireguardIPHostPart}.${toString interfacePart}";
  wireguardIPv6Prefix = "fdee:b0de:54e6:ae74::";
  wireguardIPv6Create = interfacePart: "${wireguardIPv6Prefix}${toString interfacePart}";

  wireguardPeers = {
    server = {
      IPv4 = wireguardIPHostCreate 1;
      IPv6 = wireguardIPv6Create 1;
    };
    desktop = {
      IPv4 = wireguardIPHostCreate 2;
      IPv6 = wireguardIPv6Create 2;
    };
    phone = {
      IPv4 = wireguardIPHostCreate 3;
      IPv6 = wireguardIPv6Create 3;
    };
  };
}
