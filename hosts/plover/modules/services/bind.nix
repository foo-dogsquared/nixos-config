{ config, lib, pkgs, ... }:

let
  inherit (config.networking) domain fqdn;
  inherit (import ../hardware/networks.nix) privateIPv6Prefix interfaces clientNetworks serverNetworks secondaryNameServers wireguardPeers;
  secondaryNameserverDomains = lib.attrNames secondaryNameServers;
  secondaryNameServersIPv4 = lib.foldl'
    (total: addresses: total ++ addresses.IPv4)
    [ ]
    (lib.attrValues secondaryNameServers);
  secondaryNameServersIPv6 = lib.foldl'
    (total: addresses: total ++ addresses.IPv6)
    [ ]
    (lib.attrValues secondaryNameServers);
  secondaryNameServersIPs = secondaryNameServersIPv4 ++ secondaryNameServersIPv6;

  serviceUser = config.users.users.named.name;

  domainZone = pkgs.substituteAll {
    src = ../../config/dns/${domain}.zone;
    ploverWANIPv4 = interfaces.wan.IPv4.address;
    ploverWANIPv6 = interfaces.wan.IPv6.address;
  };

  fqdnZone = pkgs.substituteAll {
    src = ../../config/dns/${fqdn}.zone;
    ploverLANIPv4 = interfaces.lan.IPv4.address;
    ploverLANIPv6 = interfaces.lan.IPv6.address;
  };

  zonesDir = "/etc/bind/zones";
  zoneFile = domain: "${zonesDir}/${domain}.zone";

  localhostIP = [
    "127.0.0.1"
    "::1"
  ];

  allowedLANIPs = [
    # Loopback address
    "127.0.0.0/8"

    # Private uses
    "10.48.0.0/12"
    "172.27.0.0/16" # The private subnet for our internal network.
    "172.28.0.0/16" # The Wireguard subnet.
  ];

  allowedLANIPv6s = [
    "::1" # Loopback
    "${privateIPv6Prefix}::/48" # Private uses
  ];

  internalsACL = clientNetworks ++ serverNetworks;
in
{
  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ../../secrets/secrets.yaml;
      };
      getSecrets = secrets:
        lib.mapAttrs'
          (secret: config:
            lib.nameValuePair
              "plover/${secret}"
              ((getKey secret) // config))
          secrets;
    in
    getSecrets {
      "dns/${domain}/mailbox-security-key" = { };
      "dns/${domain}/mailbox-security-key-record" = { };

      "dns/${domain}/rfc2136-key" = {
        owner = serviceUser;
        group = "root";
        reloadUnits = [ "bind.service" ];
        mode = "0400";
      };
    };

  # Install the utilities.
  environment.systemPackages = [ config.services.bind.package ];

  services.bind = {
    enable = true;
    forward = "first";

    cacheNetworks = [
      "127.0.0.1"
      "::1"
    ];

    listenOn = [
      "127.0.0.1"
      interfaces.lan.IPv4.address
      interfaces.wan.IPv4.address
    ];

    listenOnIpv6 = [
      "::1"
      interfaces.lan.IPv6.address
      interfaces.wan.IPv6.address
    ];

    extraConfig = ''
      include "${config.sops.secrets."plover/dns/${domain}/rfc2136-key".path}";
      acl trusted { ${lib.concatStringsSep "; " internalsACL}; localhost; };

      view external {
        match-clients { any; };

        forwarders { };
        empty-zones-enable yes;
        allow-query { any; };
        allow-recursion { none; };

        zone "${domain}" {
          type primary;

          file "${zoneFile domain}";
          allow-transfer { ${lib.concatStringsSep "; " secondaryNameServersIPs}; };
          update-policy {
            grant rfc2136key.${domain}. zonesub TXT;
          };
        };
      };

      view internal {
        match-clients { trusted; };
        allow-recursion { any; };
        forwarders { 127.0.0.53 port 53; };

        zone "${fqdn}" {
          type primary;
          file "${zoneFile fqdn}";
        };

        zone "${domain}" {
          in-view external;
        };
      };
    '';
  };

  networking.firewall ={
    allowedUDPPorts = [
      53  # DNS
      853 # DNS-over-TLS/DNS-over-QUIC
    ];
    allowedTCPPorts = [ 53 853 ];
  };
}
