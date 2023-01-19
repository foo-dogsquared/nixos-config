# It just contains a set of network-related variables mainly used for
# network-related services. Make sure to change this every time you migrate to
# a new server.
rec {
  publicIP = "95.217.212.19";
  publicIPPrefixLength = 32;
  publicIP' = "${publicIP}/${publicIPPrefixLength}";

  publicIPv6 = "2a01:4f9:c011:a448::";
  publicIPv6PrefixLength = 64;
  publicIPv6' = "${publicIPv6}/${publicIPv6PrefixLength}";

  privateIPNetworkRange = "172.16.0.0/32";
  privateNetworkGatewayIP = "172.16.0.1/32";

  wireguardIPv6BaseAddress = "fdee:b0de:54e6::";
  wireguardPort = 51820;
}
