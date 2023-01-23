{ config, lib, pkgs, ... }:

# Take note this service is heavily based on the hardware networking setup of
# this host so better stay focused on the hardware configuration on this host.
let
  acmeName = "wireguard.${config.networking.domain}";
  inherit (builtins) toString;
  inherit (import ../hardware/networks.nix)
    privateIP' privateIPv6'
    wireguardPort wireguardPeers;

  wireguardIFName = "wireguard0";

  wireguardAllowedIPs = [ privateIP' privateIPv6' ];

  desktopPeerAddresses = with wireguardPeers.desktop; [ "${IPv4}/32" "${IPv6}/128" ];
  phonePeerAddresses = with wireguardPeers.phone; [ "${IPv4}/32" "${IPv6}/128" ];
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
            AllowedIPs = lib.concatStringsSep "," (desktopPeerAddresses ++ wireguardAllowedIPs);
          };
        }

        # Phone.
        {
          wireguardPeerConfig = {
            PublicKey = lib.readFile ../../files/wireguard/wireguard-public-key-phone;
            PresharedKeyFile = config.sops.secrets."plover/wireguard/preshared-keys/phone".path;
            AllowedIPs = lib.concatStringsSep "," (phonePeerAddresses ++ wireguardAllowedIPs);
          };
        }
      ];
    };

    networks."99-${wireguardIFName}" = {
      matchConfig.Name = wireguardIFName;
      address = with wireguardPeers.server; [
        "${IPv4}/24"
        "${IPv6}/64"
      ];
    };
  };
}
