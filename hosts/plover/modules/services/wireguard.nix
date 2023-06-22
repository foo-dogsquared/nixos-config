{ config, lib, pkgs, ... }:

# Take note this service is heavily based on the hardware networking setup of
# this host so better stay focused on the hardware configuration on this host.
let
  acmeName = "wireguard.${config.networking.domain}";
  inherit (builtins) toString;
  inherit (import ../hardware/networks.nix) interfaces wireguardPort wireguardPeers;

  wireguardIFName = interfaces.wireguard0.ifname;
  lanIFName = interfaces.lan.ifname;

  desktopPeerAddresses = with wireguardPeers.desktop; [ "${IPv4}/32" "${IPv6}/128" ];
  phonePeerAddresses = with wireguardPeers.phone; [ "${IPv4}/32" "${IPv6}/128" ];

in
{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.firewall = {
    # Allow the UDP traffic for the Wireguard service.
    allowedUDPPorts = [ wireguardPort ];

    # IP forwarding for specific interfaces.
    filterForward = true;
    extraForwardRules = ''
      iifname ${wireguardIFName} accept comment "IP forward from Wireguard interface to LAN"
    '';
  };

  networking.nftables.ruleset = ''
    table ip wireguard-${wireguardIFName} {
      chain prerouting {
        type nat hook prerouting priority filter; policy accept;
      }

      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        iifname ${wireguardIFName} snat to ${interfaces.lan.IPv4.address} comment "Make packets from Wireguard interface appear as coming from the LAN interface"
      }
    }
  '';

  # Since we're using systemd-networkd to configure interfaces, we can control
  # how each interface can handle things such as IP masquerading so no need for
  # modifying sysctl settings like 'ipv4.ip_forward' or similar.
  systemd.network = {
    wait-online.ignoredInterfaces = [ wireguardIFName ];

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
        "${IPv4.address}/14"
        "${IPv6.address}/64"
      ];
    };
  };
}
