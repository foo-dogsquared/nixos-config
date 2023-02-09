{ config, options, lib, pkgs, ... }:

# Take note we're also running with systemd-resolved which shouldn't really
# conflict much with established DNS servers default configuration considering
# it lives in 127.0.0.53 (not 127.0.0.1). So if you found some errors, that's
# on you. Either that or we can easily move the resolver somewhere else.
let
  inherit (config.networking) domain fqdn;
  inherit (import ../hardware/networks.nix) interfaces clientNetworks serverNetworks secondaryNameServers;

  dnsSubdomain = "ns1";
  dnsDomainName = "${dnsSubdomain}.${domain}";
  certs = config.security.acme.certs;
  dnsEmail = "hostmaster.${domain}";

  # This is the part of the SOA record. You'll have to modify it here instead
  # of modifying a zone file since it does not play well with a dynamically
  # configured server it seems.
  dnsSerialNumber = "2023020800";
	dnsRefresh = "3h";
	dnsUpdateRetry = "15m";
	dnsExpiry = "3w";
	dnsNxTTL = "3h";

  corednsServiceName = "coredns";

  domainZoneFile = pkgs.substituteAll {
    src = ../../config/coredns/${domain}.zone;
    inherit domain dnsSubdomain;
    email = dnsEmail;
    publicIPv4 = interfaces.main'.IPv4.address;
    publicIPv6 = interfaces.main'.IPv6.address;
  };

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

  # The final location of the thing.
  domainZoneFile' = "/etc/coredns/zones/${domain}.zone";
in
{
  sops.secrets = let
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
      "dns/mailbox-security-key" = { };
      "dns/mailbox-security-key-record" = { };
    };

  # Generating a certificate for the DNS-over-TLS feature.
  security.acme.certs."${dnsDomainName}".postRun = ''
    systemctl restart ${corednsServiceName}.service
  '';

  # Setting up the firewall to make less things to screw up in case anything is
  # screwed up.
  networking.firewall.extraInputRules = ''
    meta l4proto {tcp, udp} th dport 53 ip saddr { ${lib.concatStringsSep ", " secondaryNameServersIPv4} } accept comment "Accept DNS queries from secondary nameservers"
    meta l4proto {tcp, udp} th dport 53 ip6 saddr { ${lib.concatStringsSep ", " secondaryNameServersIPv6} } accept comment "Accept DNS queries from secondary nameservers"
  '';

  # The main DNS server.
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
      (common) {
        forward . /etc/resolv.conf
        log
        cache
        errors
      }

      ${fqdn} {
        import common

        bind ${interfaces.internal.IPv4.address} ${interfaces.internal.IPv6.address}

        local

        acl {
          allow net ${lib.concatStringsSep " " (clientNetworks ++ serverNetworks)}
          block
        }

        # We're just setting up a dummy SOA. If the authority section is
        # missing, it will be considered invalid and might not play nice with
        # the other things that rely on the DNS server so we'll play nice.
        template ANY ANY {
          authority "{{ .Zone }} IN SOA {{ .Zone }} ${dnsEmail} (1 60 60 60 60)"
          fallthrough
        }

        template IN A {
          answer "{{ .Zone }} IN 60 A ${interfaces.internal.IPv4.address}"
          answer "{{ .Zone }} IN 60 A ${interfaces.internal.IPv4.address}"
        }

        template IN AAAA {
          answer "{{ .Zone }} IN 60 AAAA ${interfaces.internal.IPv6.address}"
          answer "{{ .Zone }} IN 60 AAAA ${interfaces.internal.IPv6.address}"
        }
      }

      ${domain} {
        import common

        bind lo {
          # These are already taken from systemd-resolved.
          except 127.0.0.53 127.0.0.54
        }

        acl {
          # We're setting this up as a "hidden" primary server.
          allow type AXFR net ${lib.concatStringsSep " " secondaryNameServersIPs}
          allow type IXFR net ${lib.concatStringsSep " " secondaryNameServersIPs}
          block type AXFR
          block type IXFR
        }

        template IN NS {
          ${lib.concatStringsSep "\n    "
            (lib.lists.map
              (ns: ''answer "{{ .Zone }} IN NS ${ns}"'')
              secondaryNameserverDomains)}
        }

        file ${domainZoneFile'}

        transfer {
          to *
        }
      }

      tls://${domain} {
        import common

        tls {$CREDENTIALS_DIRECTORY}/cert.pem {$CREDENTIALS_DIRECTORY}/key.pem {$CREDENTIALS_DIRECTORY}/fullchain.pem
      }
    '';
  };

  # This is based from the Gitea pre-start script.
  systemd.services.${corednsServiceName} = {
    requires = [ "acme-finished-${dnsDomainName}.target" ];
    preStart =
      let
        secretsPath = path: config.sops.secrets."plover/${path}".path;
        replaceSecretBin = "${lib.getBin pkgs.replace-secret}/bin/replace-secret";
      in
      lib.mkBefore ''
        install -Dm0644 ${domainZoneFile} ${domainZoneFile'}

        ${replaceSecretBin} '#mailboxSecurityKey#' '${secretsPath "dns/mailbox-security-key"}' '${domainZoneFile'}'
        ${replaceSecretBin} '#mailboxSecurityKeyRecord#' '${secretsPath "dns/mailbox-security-key-record"}' '${domainZoneFile'}'
      '';
    serviceConfig.LoadCredential = let
      certDirectory = certs."${dnsDomainName}".directory;
    in
    [
      "cert.pem:${certDirectory}/cert.pem"
      "key.pem:${certDirectory}/key.pem"
      "fullchain.pem:${certDirectory}/fullchain.pem"
    ];
  };
}
