{ config, lib, pkgs, ... }:

let
  certs = config.security.acme.certs;

  networks = import ../hardware/networks.nix;
  inherit (networks) publicIP publicIPv6 privateNetworkGatewayIP;

  vpnAddressPoolStart = "172.43.1.1";
  vpnAddressPoolEnd = "172.43.1.255";

  acmeName = "openvpn.foodogsquared.one";
in
{
  # We need a bridge to access locally hosted services in the network of the
  # deployed server.
  services.openvpn.servers = {
    server = {
      config =
        let
          certDirectory = certs."${acmeName}".directory;
          dhParams = config.security.dhparams.params;
        in
        ''
          ca ${certDirectory}/chain.pem
          cert ${certDirectory}/fullchain.pem
          key ${certDirectory}/key.pem
          dh ${dhParams."openvpn-server".path}

          proto udp
          topology subnet

          server-bridge 172.43.0.1 255.255.255.0 ${vpnAddressPoolStart} ${vpnAddressPoolEnd}
          server-ipv6 fd00::/8

          dev vpn-tap
          dev-type tap

          # Connecting clients will be able to reach to one another.
          client-to-client

          user nobody
          group nobody
        '';
    };
  };

  # We're generating our own certificates for OpenVPN. Most of the
  # configuration should be taken care of with the defaults from the host
  # config.
  security.acme.certs."${acmeName}" = { };

  # For key generation, debugging, panic configuration, anything else.
  environment.systemPackages = [ pkgs.openvpn ];

  systemd.network =
    let
      vpnBridgeIFName = "vpn-bridge";
      vpnTapIFName = "vpn-tap";
    in
    {
      netdevs = {
        "90-${vpnBridgeIFName}".netdevConfig = {
          Name = vpnBridgeIFName;
          Kind = "bridge";
        };

        "90-${vpnTapIFName}" = {
          netdevConfig = {
            Name = vpnTapIFName;
            Kind = "tap";
          };

          tapConfig = {
            MultiQueue = true;
            PacketInfo = true;
          };
        };
      };

      networks = {
        "50-vpn-bridge-slave-1" = {
          matchConfig.MACAddress = "86:00:00:32:48:20";
          networkConfig.Bridge = vpnBridgeIFName;
        };

        "50-vpn-bridge-slave-tap" = {
          matchConfig.Name = vpnTapIFName;
          networkConfig.Bridge = vpnBridgeIFName;
        };

        "50-vpn-bridge-static" = {
          matchConfig.Name = vpnBridgeIFName;

          address = [
            # The private network IP.
            "172.43.0.1/32"

            # Generate a new unique local IPv6 address.
            "::"
          ];

          gateway = [ privateNetworkGatewayIP ];
        };
      };
    };

  security.dhparams.params.openvpn-server = { };
}
