{ config, options, lib, pkgs, ... }:

# Take note we're also running with systemd-resolved which shouldn't really
# conflict much with established DNS servers default configuration considering
# it lives in 127.0.0.53 (not 127.0.0.1). So if you found some errors, that's
# on you. Either that or we can easily move the resolver somewhere else.
let
  inherit (config.networking) domain fqdn;
  inherit (import ../hardware/networks.nix) privateIPv6Prefix interfaces clientNetworks serverNetworks secondaryNameServers wireguardPeers;

  domainZoneFile = pkgs.substituteAll {
    src = ../../config/coredns/${domain}.zone;
    ploverPublicIPv4 = interfaces.main'.IPv4.address;
    ploverPublicIPv6 = interfaces.main'.IPv6.address;
  };

  # The final location of the thing.
  domainZoneFile' = "/etc/coredns/zones/${domain}.zone";

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

  # The local network segments.
  allowedIPs = secondaryNameServersIPv4 ++ [
    # Loopback address
    "127.0.0.0/8"

    # Private uses
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
  ];
  allowedIPv6s = secondaryNameServersIPv6 ++ [
    "::1" # Loopback
    "${privateIPv6Prefix}::/48" # Private uses
  ];

  mainIP = with interfaces.main'; [
    IPv4.address
    IPv6.address
  ];

  internalIP = with interfaces.internal; [
    IPv4.address
    IPv6.address
  ];

  wireguardIP = with wireguardPeers.server; [
    IPv4 IPv6
  ];

  dnsListenInterfaces = (with interfaces; [
    "127.0.0.1"
    "::1"
  ]) ++ mainIP ++ internalIP ++ wireguardPeers;
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

  # Setting up the firewall to make less things to screw up in case anything is
  # screwed up.
  networking.firewall.extraInputRules = ''
    meta l4proto {tcp, udp} th dport domain ip saddr { ${lib.concatStringsSep ", " allowedIPs} } accept comment "Accept DNS queries from secondary nameservers and private networks"
    meta l4proto {tcp, udp} th dport domain ip6 saddr { ${lib.concatStringsSep ", " allowedIPv6s} } accept comment "Accept DNS queries from secondary nameservers and private networks"
  '';

  # For more information how the server is set up, you could take a look at the
  # hardware networking configuration.
  services.coredns = {
    enable = true;

    # NOTE: Currently, Hetzner DNS servers does not support DNSSEC. Will need
    # to visit the following document periodically to see if they support but
    # it is doubtful since they are doubting the benefits of supporting it. :(
    #
    # From what I can tell, it seems like DNSSEC is not much embraced by the
    # major organizations yet so I'll wait with them on this one.
    #
    # https://docs.hetzner.com/dns-console/dns/general/dnssec
    config = ''
      # The LAN.
      ${fqdn} {
        bind ${interfaces.internal.ifname}
        acl {
          # Hetzner doesn't support DNSSEC yet though.
          block type DS SIG RRSIG TA TSIG PTR DLV DNSKEY KEY NSEC NSEC3

          allow net ${lib.concatStringsSep " " (clientNetworks ++ serverNetworks)}
          allow net 127.0.0.0/8 ::1
          block
        }

        template IN A {
          answer "{{ .Name }} IN 60 A ${interfaces.internal.IPv4.address}"
        }

        template IN AAAA {
          answer "{{ .Name }} IN 60 AAAA ${interfaces.internal.IPv6.address}"
        }
      }

      # The WAN.
      ${domain} {
        bind ${interfaces.main'.ifname}

        acl {
          # We're setting this up as a "hidden" primary server.
          allow type AXFR net ${lib.concatStringsSep " " secondaryNameServersIPs}
          allow type IXFR net ${lib.concatStringsSep " " secondaryNameServersIPs}

          # This will allow internal clients connect to the subdomains that
          # have internal resources.
          allow net ${lib.concatStringsSep " " (clientNetworks ++ serverNetworks)}
          allow net 127.0.0.0/8 ::1

          # Otherwise, it's just really a primary server that is hidden
          # somewhere (or just very shy, whichever of the two).
          block
        }

        file ${domainZoneFile'} {
          reload 30s
        }

        transfer {
          to ${lib.concatStringsSep " " secondaryNameServersIPs}
        }
      }

      # The NAN.
      . {
        cache
        forward . /etc/resolv.conf

        log ${domain} {
          class success error
        }

        errors {
          consolidate 1m "^.* no next plugin found$"
        }
      }
    '';
  };
}
