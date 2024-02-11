{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.networking.wireguard;

  networkSetup = hostCfg.networking.setup;

  inherit (builtins) toString;
  inherit (import ../../../plover/modules/hardware/networks.nix)
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
  options.hosts.ni.networking.wireguard.enable = lib.mkEnableOption "Wireguard setup";

  config = lib.mkIf (hostCfg.networking.enable && cfg.enable) (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [ wireguard-tools ];
      networking.firewall.allowedUDPPorts = [ wireguardPort ];
      sops.secrets = foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
        "wireguard/private-key" = { };
        "wireguard/preshared-keys/plover" = { };
        "wireguard/preshared-keys/phone" = { };
      };
    }

    (lib.mkIf (networkSetup == "networkmanager") {
      networking.networkmanager.ensureProfiles.profiles = {
        personal-vpn = {
          connection = {
            id = "Plover VPN";
            type = "wireguard";
            interface-name = "wireguard0";

            autoconnect = false;
            dns-over-tls = "opportunistic";
          };
          wireguard = {
            peer-routes = true;
            listen-port = wireguardPort;
          };
        };
      };

      networking.wg-quick.interfaces.wireguard0 = {
        privateKeyFile = config.sops.secrets."wireguard/private-key".path;
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
            publicKey = lib.removeSuffix "\n" (lib.readFile ../../../plover/files/wireguard/wireguard-public-key-plover);
            presharedKeyFile = config.sops.secrets."wireguard/preshared-keys/plover".path;
            allowedIPs = wireguardAllowedIPs;
            endpoint = "${interfaces.wan.IPv4.address}:${toString wireguardPort}";
            persistentKeepalive = 25;
          }

          # The "phone" peer.
          {
            publicKey = lib.removeSuffix "\n" (lib.readFile ../../../plover/files/wireguard/wireguard-public-key-phone);
            presharedKeyFile = config.sops.secrets."wireguard/preshared-keys/phone".path;
            allowedIPs = wireguardAllowedIPs;
          }
        ];
      };
    })

    (lib.mkIf (networkSetup == "networkd") {
      # Just apply the appropriate permissions for systemd-networkd.
      sops.secrets =
        let
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
          "wireguard/private-key"
          "wireguard/preshared-keys/phone"
          "wireguard/preshared-keys/plover"
        ];

      systemd.network = {
        netdevs."99-${wireguardIFName}" = {
          netdevConfig = {
            Name = wireguardIFName;
            Kind = "wireguard";
          };

          wireguardConfig = {
            PrivateKeyFile = config.sops.secrets."wireguard/private-key";
            ListenPort = wireguardPort;
          };

          wireguardPeers = [
            # The "server" peer.
            {
              PublicKey = lib.readFile ../../../plover/files/wireguard/wireguard-public-key-plover;
              PresharedKeyFile = config.sops.secrets."wireguard/preshared-keys/plover".path;
              AllowedIPs = lib.concatStringsSep "," wireguardAllowedIPs;
              Endpoint = "${interfaces.wan.IPv4.address}:${toString wireguardPort}";
              PersistentKeepalive = 25;
            }

            # The "phone" peer.
            {
              PublicKey = lib.readFile ../../../plover/files/wireguard/wireguard-public-key-phone;
              PresharedKeyFile = config.sops.secrets."wireguard/preshared-keys/phone".path;
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
  ]);
}
