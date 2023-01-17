# It just contains a set of network-related variables mainly used for
# network-related services. Make sure to change this every time you migrate to
# a new server.
{
  publicIP = "95.217.212.19/32";
  publicIPv6 = "2a01:4f9:c011:a448::";

  privateIPNetworkRange = "172.16.0.0/32";
  privateNetworkGatewayIP = "172.16.0.1/32";

  wireguardIPv6BaseAddress = "fdee:b0de:54e6::";
  wireguardPort = 51820;
}
