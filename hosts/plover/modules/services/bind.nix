# The DNS server for my domains. Take note it uses a hidden master setup with
# the secondary nameservers of the service (as of 2023-10-05, we're using
# Hetzner's secondary nameservers).
{ config, lib, pkgs, ... }:

let
  inherit (config.networking) domain fqdn;
  inherit (import ../hardware/networks.nix) interfaces clientNetworks serverNetworks secondaryNameServers;
  secondaryNameServersIPs = lib.foldl'
    (total: addresses: total ++ addresses.IPv4 ++ addresses.IPv6)
    [ ]
    (lib.attrValues secondaryNameServers);

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

  dnsSubdomain = "ns1.${domain}";
  dnsOverHTTPSPort = 8443;
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
      "dns/${domain}/mailbox-security-key" = dnsFileAttribute;
      "dns/${domain}/mailbox-security-key-record" = dnsFileAttribute;
      "dns/${domain}/keybase-verification-key" = dnsFileAttribute;
      "dns/${domain}/rfc2136-key" = dnsFileAttribute // {
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
        certDir = path: "/run/credentials/bind.service/${path}";
        listenInterfaces = lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOn;
        listenInterfacesIpv6 = lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOnIpv6;
      in
      pkgs.writeText "named.conf" ''
        include "/etc/bind/rndc.key";
        include "${config.sops.secrets."dns/${domain}/rfc2136-key".path}";

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

        http ${dnsSubdomain} {
          endpoints { "/dns-query"; };
        };

        acl trusted { ${lib.concatStringsSep "; " (clientNetworks ++ serverNetworks)}; localhost; };
        acl cachenetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.cacheNetworks} };
        acl badnetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.blockedNetworks} };

        options {
          # Native DNS.
          listen-on { ${listenInterfaces} };
          listen-on-v6 { ${listenInterfacesIpv6} };

          # DNS-over-TLS.
          listen-on tls ${dnsSubdomain} { ${listenInterfaces} };
          listen-on-v6 tls ${dnsSubdomain} { ${listenInterfacesIpv6} };

          # DNS-over-HTTPS.
          https-port ${builtins.toString dnsOverHTTPSPort};
          listen-on tls ${dnsSubdomain} http ${dnsSubdomain} { ${listenInterfaces} };
          listen-on-v6 tls ${dnsSubdomain} http ${dnsSubdomain} { ${listenInterfacesIpv6} };

          allow-query { cachenetworks; };
          blackhole { badnetworks; };
          forward ${cfg.forward};
          forwarders { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.forwarders} };
          directory "${cfg.directory}";
          pid-file "/run/named/named.pid";
        };

        view internal {
          match-clients { trusted; };

          allow-query { any; };
          allow-recursion { any; };

          // We'll use systemd-resolved as our forwarder.
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

        ${cfg.extraConfig}
      '';
  };

  systemd.services.bind = {
    path = with pkgs; [ replace-secret ];
    preStart =
      let
        domainZone' = zoneFile domain;
        fqdnZone' = zoneFile fqdn;
        secretPath = path: config.sops.secrets."dns/${path}".path;
      in
      lib.mkAfter ''
        [ -f '${domainZone'}' ] || {
          install -Dm0600 '${domainZone}' '${domainZone'}'
          replace-secret '#mailboxSecurityKey#' '${secretPath "${domain}/mailbox-security-key"}' '${domainZone'}'
          replace-secret '#mailboxSecurityKeyRecord#' '${secretPath "${domain}/mailbox-security-key-record"}' '${domainZone'}'
        }

        [ -f '${fqdnZone'}' ] || {
          install -Dm0600 '${fqdnZone}' '${fqdnZone'}'
        }
      '';

    serviceConfig = {
      # Additional service hardening. You can see most of the options from
      # systemd.exec(5) manual. Run it as an unprivileged user.
      User = config.users.users.named.name;
      Group = config.users.users.named.group;
      UMask = "0037";

      # Get the credentials into the service.
      LoadCredential =
        let
          certDirectory = config.security.acme.certs."${dnsSubdomain}".directory;
          certCredentialPath = path: "${path}:${certDirectory}/${path}";
        in
        [
          (certCredentialPath "cert.pem")
          (certCredentialPath "key.pem")
          (certCredentialPath "fullchain.pem")
        ];

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
      ConfigurationDirectory = "bind";
      ConfigurationDirectoryMode = "0755";

      # Filtering system calls.
      SystemCallFilter = [ "@system-service" ];
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";

      # Granting and restricting its capabilities. Take note we're not using
      # syslog for this even if the application can so no syslog capability.
      # Additionally, we're using omitting the program's ability to chroot and
      # chown since the user and the directories are already configured.
      CapabilityBoundingSet = [
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_RAW"
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

  # Set up the firewall. Take note the ports with the transport layer being
  # accepted in Bind.
  networking.firewall =
    let
      ports = [
        53 # DNS
        853 # DNS-over-TLS/DNS-over-QUIC
        dnsOverHTTPSPort
      ];
    in
    {
      allowedUDPPorts = ports;
      allowedTCPPorts = ports;
    };

  # Making this with nginx.
  services.nginx.upstreams.local-dns = {
    extraConfig = ''
      zone dns 64k;
    '';
    servers = {
      "127.0.0.1:${builtins.toString dnsOverHTTPSPort}" = { };
    };
  };

  services.nginx.virtualHosts."${dnsSubdomain}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    extraConfig = ''
      add_header Strict-Transport-Security max-age=31536000;
    '';
    kTLS = true;
    locations = {
      "/".return = "444";
      "/dns-query".extraConfig = ''
        grpc_pass grpcs://local-dns;
        grpc_socket_keepalive on;
        grpc_connect_timeout 10s;
        grpc_ssl_verify off;
        grpc_ssl_protocols TLSv1.3 TLSv1.2;
      '';
    };
  };

  # Then generate a DH parameter for the application.
  security.dhparams.params.bind.bits = 4096;

  # Set up a fail2ban which is apparently already available in the package.
  services.fail2ban.jails."named-refused".settings = {
    enabled = true;
    backend = "systemd";
    filter = "named-refused[journalmatch='_SYSTEMD_UNIT=bind.service']";
    maxretry = 3;
  };

  # Add the following to be backed up.
  services.borgbackup.jobs.services-backup.paths = [ zonesDir ];
}
