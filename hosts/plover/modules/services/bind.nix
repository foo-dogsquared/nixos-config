{ config, lib, pkgs, ... }:

let
  inherit (config.networking) domain fqdn;
  inherit (import ../hardware/networks.nix) privateIPv6Prefix interfaces clientNetworks serverNetworks secondaryNameServers wireguardPeers;
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

  dnsSubdomain = "ns1.${domain}";
in
{
  sops.secrets =
    let
      dnsFileAttribute = {
        owner = config.users.users.named.name;
        group = config.users.users.named.group;
        mode = "0400";
      };
    in
    lib.getSecrets ../../secrets/secrets.yaml {
      "plover/dns/${domain}/mailbox-security-key" = dnsFileAttribute;
      "plover/dns/${domain}/mailbox-security-key-record" = dnsFileAttribute;
      "plover/dns/${domain}/rfc2136-key" = dnsFileAttribute // {
        reloadUnits = [ "bind.service" ];
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

    # Welp, since the template is pretty limited, we'll have to go with our
    # own. This is partially based from the NixOS Bind module except without
    # the template for filling in zones since we use views.
    configFile =
      let
        cfg = config.services.bind;
        certDir = path: "${config.security.acme.certs."${dnsSubdomain}".directory}/${path}";
      in
      pkgs.writeText "named.conf" ''
        include "/etc/bind/rndc.key";
        controls {
          inet 127.0.0.1 allow {localhost;} keys {"rndc-key";};
        };

        tls ${dnsSubdomain} {
          key-file "${certDir "key.pem"}";
          cert-file "${certDir "cert.pem"}";
          dhparam-file "${config.security.dhparams.params.bind.path}";
          ciphers "HIGH:!kRSA:!aNULL:!eNULL:!RC4:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!SHA1:!SHA256:!SHA384";
          prefer-server-ciphers yes;
          session-tickets no;
        };

        acl cachenetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.cacheNetworks} };
        acl badnetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.blockedNetworks} };

        options {
          listen-on { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOn} };
          listen-on-v6 { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOnIpv6} };
          allow-query { cachenetworks; };
          blackhole { badnetworks; };
          forward ${cfg.forward};
          forwarders { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.forwarders} };
          directory "${cfg.directory}";
          pid-file "/run/named/named.pid";
          ${cfg.extraOptions}
        };

        ${cfg.extraConfig}
    '';

    extraOptions = ''
      listen-on tls ${dnsSubdomain} { ${lib.concatMapStrings (interface: "${interface}; ") config.services.bind.listenOn} };
      listen-on-v6 tls ${dnsSubdomain} { ${lib.concatMapStrings (interface: "${interface}; ") config.services.bind.listenOnIpv6} };
    '';

    extraConfig = ''
      include "${config.sops.secrets."plover/dns/${domain}/rfc2136-key".path}";

      acl trusted { ${lib.concatStringsSep "; " (clientNetworks ++ serverNetworks)}; localhost; };

      view internal {
        match-clients { trusted; };

        allow-query { any; };
        allow-recursion { any; };
        forwarders { 127.0.0.53 port 53; };

        zone "${fqdn}" {
          type primary;
          file "${zoneFile fqdn}";
        };

        zone "${domain}" {
          type primary;

          file "${zoneFile domain}";
          allow-transfer { ${lib.concatStringsSep "; " secondaryNameServersIPs}; };
          update-policy {
            grant rfc2136key.${domain}. zonesub TXT;
          };
        };
      };

      view external {
        match-clients { any; };

        forwarders { };
        empty-zones-enable yes;
        allow-query { any; };
        allow-recursion { none; };

        zone "${domain}" {
          in-view internal;
        };
      };
    '';
  };

  systemd.services.bind = {
    path = with pkgs; [ replace-secret ];
    preStart =
      let
        domainZone' = zoneFile domain;
        fqdnZone' = zoneFile fqdn;
        secretPath = path: config.sops.secrets."plover/dns/${path}".path;
      in lib.mkAfter ''
        [ -f '${domainZone'}' ] || {
          install -Dm0600 '${domainZone}' '${domainZone'}'
          replace-secret #mailboxSecurityKey# '${secretPath "${domain}/mailbox-security-key"}' '${domainZone'}'
          replace-secret #mailboxSecurityKeyRecord# '${secretPath "${domain}/mailbox-security-key-record"}' '${domainZone'}'
        }

        [ -f '${fqdnZone'}' ] || {
          install -Dm0600 '${fqdnZone}' '${fqdnZone'}'
        }
    '';

    serviceConfig = {
      # Additional service hardening. You can see most of the options
      # from systemd.exec(5) manual.
      # Run it as an unprivileged user.
      User = config.users.users.named.name;
      Group = config.users.users.named.group;
      UMask = "0037";

      # Lock and protect various system components.
      LockPersonality = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectProc = "invisible";

      # Make the filesystem invisible to the service.
      ProtectSystem = "strict";
      ReadWritePaths = [
        config.services.bind.directory
        "/etc/bind"
      ];
      ReadOnlyPaths = [
        config.security.dhparams.params.bind.path
        config.security.acme.certs."${dnsSubdomain}".directory
      ];

      # Set up writable directories.
      RuntimeDirectory = "named";
      RuntimeDirectoryMode = "0750";
      CacheDirectory = "named";
      CacheDirectoryMode = "0750";

      # Filtering system calls.
      SystemCallFilter = [ "@system-service" ];
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";

      # Granting and restricting its capabilities. Take note we're not using
      # syslog for this even if the application can so no syslog capability.
      CapabilityBoundingSet = [
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_RAW"
        "CAP_CHOWN"
        "CAP_SYS_CHROOT"
      ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

      # Restrict what address families can it access.
      RestrictAddressFamilies = [
        "AF_LOCAL"
        "AF_NETLINK"
        "AF_BRIDGE"
        "AF_INET"
        "AF_INET6"
      ];

      # Restricting what namespaces it can create.
      RestrictNamespaces = true;
    };
  };

  # Set up the firewall.
  networking.firewall = {
    allowedUDPPorts = [
      53 # DNS
      853 # DNS-over-TLS/DNS-over-QUIC
    ];
    allowedTCPPorts = [ 53 853 ];
  };

  # Setting up DNS-over-TLS by generating a certificate.
  security.acme.certs."${dnsSubdomain}".group = config.users.users.named.group;

  # Then generate a DH parameter for the application.
  security.dhparams.params.bind.bits = 4096;

  # Set up a fail2ban which is apparently already available in the package.
  services.fail2ban.jails."named-refused" = ''
    enabled = true
    backend = systemd
    filter = named-refused[journalmatch='_SYSTEMD_UNIT=bind.service']
    maxretry = 3
  '';

  # Add the following to be backed up.
  services.borgbackup.jobs.services-backup.paths = [ zonesDir ];
}
