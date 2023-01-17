{ config, lib, pkgs, ... }:

# Take note this service is heavily based on the hardware networking setup of
# this host so better stay focused on the hardware configuration on this host.
let
  acmeName = "wireguard.${config.networking.domain}";
  networks = import ../hardware/networks.nix;
  inherit (networks) privateNetworkGatewayIP wireguardIPv6BaseAddress wireguardPort;

  wireguardIFName = "wireguard0";
  wireguardAddresses = [
    # Private IP address.
    "172.45.1.1/32"

    # Private IPv6 address. Just arbitrarily chosen.
    "${wireguardIPv6BaseAddress}/48"
  ];
  wireguardAllowedIPs = [ "172.45.1.2/24" "${wireguardIPv6BaseAddress}/48" ];
in
{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.firewall.allowedUDPPorts = [ wireguardPort ];

  systemd.network = {
    netdevs."99-${wireguardIFName}" = {
      netdevConfig = {
        Name = wireguardIFName;
        Kind = "wireguard";
      };

      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."plover/wireguard/private-key".path;
        ListenPort = wireguardPort;
      };

      wireguardPeers = [
        # Desktop workstation.
        {
          wireguardPeerConfig = {
            PublicKey = lib.readFile ../../../ni/files/wireguard/wireguard-public-key-ni;
            PresharedKeyFile = config.sops.secrets."plover/wireguard/preshared-keys/ni".path;
            AllowedIPs = lib.concatStringsSep "," wireguardAllowedIPs;
          };
        }

        # Phone.
        {
          wireguardPeerConfig = {
            PublicKey = lib.readFile ../../files/wireguard/wireguard-public-key-phone;
            PresharedKeyFile = config.sops.secrets."plover/wireguard/preshared-keys/phone".path;
            AllowedIPs = lib.concatStringsSep "," wireguardAllowedIPs;
          };
        }
      ];
    };

    networks."99-${wireguardIFName}" = {
      matchConfig.Name = wireguardIFName;

      address = wireguardAddresses;

      gateway = [ privateNetworkGatewayIP ];
    };
  };
}
