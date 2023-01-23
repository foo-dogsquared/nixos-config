{ config, lib, pkgs, ... }:

# Take note this service is heavily based on the hardware networking setup of
# this host so better stay focused on the hardware configuration on this host.
let
  acmeName = "wireguard.${config.networking.domain}";
  inherit (builtins) toString;
  inherit (import ../hardware/networks.nix) interfaces wireguardPort wireguardPeers;

  wireguardIFName = "wireguard0";

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
            AllowedIPs = lib.concatStringsSep "," desktopPeerAddresses;
          };
        }

        # Phone.
        {
          wireguardPeerConfig = {
            PublicKey = lib.readFile ../../files/wireguard/wireguard-public-key-phone;
            PresharedKeyFile = config.sops.secrets."plover/wireguard/preshared-keys/phone".path;
            AllowedIPs = lib.concatStringsSep "," phonePeerAddresses;
          };
        }
      ];
    };

    networks."99-${wireguardIFName}" = {
      matchConfig.Name = wireguardIFName;
      address = with interfaces.wireguard0; [
        "${IPv4}/32"
        "${IPv6}/128"
      ];

      routes = [
        {
          routeConfig = {
            Gateway = wireguardPeers.server.IPv4;
            Destination = let
              ip = lib.strings.splitString "." wireguardPeers.server.IPv4;
              properRange = lib.lists.take 3 ip ++ [ "0" ];
              ip' = lib.concatStringsSep "." properRange;
            in "${ip'}/16";
          };
        }
      ];
    };
  };
}
