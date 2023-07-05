{ config, lib, pkgs, ... }:

let
  network = import ../../plover/modules/hardware/networks.nix;
  inherit (builtins) toString;
  inherit (network)
    interfaces
    wireguardPort
    wireguardPeers;

  wireguardAllowedIPs = [
    "${interfaces.lan.IPv4.address}/16"
    "${interfaces.lan.IPv6.address}/64"
  ];
  wireguardIFName = "wireguard0";

  internalDomains = [
    "~plover.foodogsquared.one"
    "~0.27.172.in-addr.arpa"
    "~0.28.172.in-addr.arpa"
  ];
in
{
  # Setting up Wireguard as a VPN tunnel. Since this is a laptop that meant to
  # be used anywhere, we're configuring Wireguard here as a "client".
  config = lib.mkMerge [
    {
      networking.firewall.allowedUDPPorts = [ wireguardPort ];
      sops.secrets = lib.getSecrets ../secrets/secrets.yaml {
        "ni/wireguard/private-key" = { };
        "ni/wireguard/preshared-keys/plover" = { };
        "ni/wireguard/preshared-keys/phone" = { };
      };
    }

    (lib.mkIf config.networking.networkmanager.enable {
      networking.wg-quick.interfaces.wireguard0 = {
        privateKeyFile = config.sops.secrets."ni/wireguard/private-key".path;
        listenPort = wireguardPort;
        dns = with interfaces.lan; [ IPv4.address IPv6.address ];
        postUp =
          let
            resolvectl = "${lib.getBin pkgs.systemd}/bin/resolvectl";
          in
          ''
            ${resolvectl} domain ${wireguardIFName} ${lib.concatStringsSep " " internalDomains}
            ${resolvectl} dnssec ${wireguardIFName} no
          '';

        address = with wireguardPeers.desktop; [
          "${IPv4}/32"
          "${IPv6}/128"
        ];

        # Take note wg-quick doesn't trim the files so we have to trim it ourselves.
        peers = [
          # The "server" peer.
          {
            publicKey = lib.removeSuffix "\n" (lib.readFile ../../plover/files/wireguard/wireguard-public-key-plover);
            presharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/plover".path;
            allowedIPs = wireguardAllowedIPs;
            endpoint = "${interfaces.wan.IPv4.address}:${toString wireguardPort}";
            persistentKeepalive = 25;
          }

          # The "phone" peer.
          {
            publicKey = lib.removeSuffix "\n" (lib.readFile ../../plover/files/wireguard/wireguard-public-key-phone);
            presharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/phone".path;
            allowedIPs = wireguardAllowedIPs;
          }
        ];
      };
    })

    (lib.mkIf config.systemd.network.enable {
      # Just apply the appropriate permissions for systemd-networkd.
      sops.secrets = let
        systemdNetworkFileAttrs = {
          group = config.users.users.systemd-network.group;
          reloadUnits = [ "systemd-networkd.service" ];
          mode = "0640";
        };
        applySystemdAttr = secretPaths: lib.listToAttrs
          (builtins.map (path: lib.nameValuePair path systemdNetworkFileAttrs))
          secretPaths;
        in
        applySystemdAttr [
          "ni/wireguard/private-key"
          "ni/wireguard/preshared-keys/phone"
          "ni/wireguard/preshared-keys/plover"
        ];

      systemd.network = {
        netdevs."99-${wireguardIFName}" = {
          netdevConfig = {
            Name = wireguardIFName;
            Kind = "wireguard";
          };

          wireguardConfig = {
            PrivateKeyFile = config.sops.secrets."ni/wireguard/private-key";
            ListenPort = wireguardPort;
          };

          wireguardPeers = [
            # The "server" peer.
            {
              PublicKey = lib.readFile ../../plover/files/wireguard/wireguard-public-key-plover;
              PresharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/plover".path;
              AllowedIPs = lib.concatStringsSep "," wireguardAllowedIPs;
              Endpoint = "${interfaces.wan.IPv4.address}:${toString wireguardPort}";
              PersistentKeepalive = 25;
            }

            # The "phone" peer.
            {
              PublicKey = lib.readFile ../../plover/files/wireguard/wireguard-public-key-phone;
              PresharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/phone".path;
              AllowedIPs = lib.concatStringsSep "," wireguardAllowedIPs;
            }
          ];
        };

        networks."99-${wireguardIFName}" = {
          matchConfig.Name = wireguardIFName;

          address = with wireguardPeers.desktop; [
            "${IPv4}/32"
            "${IPv6}/128"
          ];

          dns = with interfaces.lan; [ IPv4.address IPv6.address ];
          domains = internalDomains;
        };
      };
    })
  ];
}
