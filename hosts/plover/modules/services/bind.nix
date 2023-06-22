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

  zonesDir = "/var/db/dns";
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
    };

  networking.nameservers = localhostIP;

  environment.etc."bind/named.conf".source = config.services.bind.configFile;

  services.bind = {
    enable = true;
    forward = "first";
    forwarders = [ "127.0.0.53 port 53" ];

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
      acl internals { ${lib.concatStringsSep "; " (clientNetworks ++ serverNetworks ++ [ "127.0.0.0/8" "::1" ])}; };
    '';

    extraOptions = ''
      allow-recursion { internals; };
      empty-zones-enable yes;
    '';

    zones = {
      "${config.networking.domain}" = {
        file = zoneFile domain;
        allowQuery = allowedLANIPs ++ allowedLANIPv6s;
        master = true;
        slaves = secondaryNameServersIPs;
        extraConfig = ''
          forwarders { };
          update-policy local;
        '';
      };

      "${config.networking.fqdn}" = {
        file = zoneFile fqdn;
        master = true;
        allowQuery = allowedLANIPs ++ allowedLANIPv6s;
        slaves = [ "none" ];
      };
    };
  };

  networking.firewall.extraInputRules =
    let
      allowedIPs = secondaryNameServersIPv4 ++ allowedLANIPs;
      allowedIPv6s = secondaryNameServersIPv6 ++ allowedLANIPv6s;
    in
    ''
      meta l4proto {tcp, udp} th dport domain ip saddr { ${lib.concatStringsSep ", " allowedIPs} } accept comment "Accept DNS queries from secondary nameservers and private networks"
      meta l4proto {tcp, udp} th dport domain ip6 saddr { ${lib.concatStringsSep ", " allowedIPv6s} } accept comment "Accept DNS queries from secondary nameservers and private networks"
      meta l4proto {tcp, udp} th dport domain-s ip saddr { ${lib.concatStringsSep ", " allowedIPs} } accept comment "Accept DNS queries from secondary nameservers and private networks"
      meta l4proto {tcp, udp} th dport domain-s ip6 saddr { ${lib.concatStringsSep ", " allowedIPv6s} } accept comment "Accept DNS queries from secondary nameservers and private networks"
    '';

  systemd.services.bind = {
    preStart = let
      secretsPath = path: config.sops.secrets."plover/${path}".path;
      replaceSecretBin = "${lib.getBin pkgs.replace-secret}/bin/replace-secret";
    in
    lib.mkBefore ''
      install -Dm0644 ${domainZone} ${zoneFile domain}
      install -Dm0644 ${fqdnZone} ${zoneFile fqdn}

      ${replaceSecretBin} '#mailboxSecurityKey#' '${secretsPath "dns/${domain}/mailbox-security-key"}' '${zoneFile domain}'
      ${replaceSecretBin} '#mailboxSecurityKeyRecord#' '${secretsPath "dns/${domain}/mailbox-security-key-record"}' '${zoneFile domain}'
    '';
  };
}
