# It just contains a set of network-related variables mainly used for
# network-related services. Make sure to change this every time you migrate to
# a new server.
let inherit (builtins) toString;
in rec {
  # This is expected to be /48 block (i.e., `fc00:b0de:5685::/48`).
  # The thing is generated using a ULA generator.
  privateIPv6Prefix = "fd89:c181:8016";

  # Wireguard-related things.
  wireguardPort = 51820;

  # This IPv4 network block should have /13 for the Wireguard network.
  wireguardIPv4Prefix = "172.28.0";

  # This IPv6 network prefix should have /64 for the entire Wireguard network.
  wireguardIPv6Prefix = "${privateIPv6Prefix}:ffff";
}
