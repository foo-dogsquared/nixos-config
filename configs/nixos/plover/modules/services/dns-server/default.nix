# The DNS server for my domains. Take note it uses a hidden master setup with
# the secondary nameservers of the service (as of 2023-10-05, we're using
# Hetzner's secondary nameservers).
{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.dns-server;

  inherit (config.networking) domain fqdn;
  inherit (config.state.network.interfaces) wan lan;

  zonesDir = "/etc/bind/zones";
  getZoneFile = domain: "${zonesDir}/${domain}.zone";

  zonefile = pkgs.substituteAll {
    src = ./zones/${domain}.zone;
    ploverWANIPv4 = wan.ipv4;
    ploverWANIPv6 = wan.ipv6;
  };

  fqdnZone = pkgs.substituteAll {
    src = ./zones/${fqdn}.zone;
    ploverLANIPv4 = wan.ipv4;
    ploverLANIPv6 = wan.ipv6;
  };

  dnsSubdomain = "ns1.${domain}";
in
{
  options.hosts.plover.services.dns-server.enable =
    lib.mkEnableOption "preferred DNS server";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.ports = {
        dns.value = 53;
        dnsOverHTTPS.value = 8443;
        dnsOverTLS.value = 853;
      };

      sops.secrets =
        let
          dnsFileAttribute = {
            owner = config.users.users.named.name;
            group = config.users.users.named.group;
            mode = "0400";
          };
        in
        foodogsquaredLib.sops-nix.getSecrets ./secrets.yaml {
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
          wan.ipv4
          lan.ipv4
        ];

        listenOnIpv6 = [
          "::1"
          wan.ipv6
          lan.ipv6
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

            acl trusted { ${lib.concatStringsSep "; " [ "10.0.0.0/8" ]}; localhost; };
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
              tls-port ${builtins.toString config.state.ports.dnsOverTLS.value};
              https-port ${builtins.toString config.state.ports.dnsOverHTTPS.value};
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
                file "${getZoneFile fqdn}";
              };

              zone "${domain}" {
                type primary;

                file "${getZoneFile domain}";
                allow-transfer { ${lib.concatStringsSep "; " config.state.network.secondaryNameservers}; };
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
            domainZone' = getZoneFile domain;
            fqdnZone' = getZoneFile fqdn;
          in
          lib.mkAfter ''
            # Install the domain zone.
            [ -f ${lib.escapeShellArg domainZone'} ] || install -Dm0600 ${zonefile} ${lib.escapeShellArg domainZone'}

            # Install the internal DNS zones.
            [ -f ${lib.escapeShellArg fqdnZone'} ] || install -Dm0600 '${fqdnZone}' ${lib.escapeShellArg fqdnZone'}
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

          LogFilterPatterns = [
            # systemd-resolved doesn't have DNS cookie support, it seems.
            "~missing expected cookie from 127.0.0.53#53"
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
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
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

      # Then generate a DH parameter for the application.
      security.dhparams.params.bind.bits = 4096;
    }

    (lib.mkIf hostCfg.services.monitoring.enable {
      state.ports.bindStatistics.value = 9423;

      services.bind.extraConfig = ''
        statistics-channels {
          inet 127.0.0.1 port ${builtins.toString config.state.ports.bindStatistics.value} allow { 127.0.0.1; };
        };
      '';

      services.prometheus.exporters = {
        bind = {
          enable = true;
          bindURI = "http://127.0.0.1/${builtins.toString config.state.ports.bindStatistics.value}";
        };
      };
    })

    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      # Making this with nginx.
      services.nginx.upstreams.local-dns = {
        extraConfig = ''
          zone dns 64k;
        '';
        servers = {
          "127.0.0.1:${builtins.toString config.state.ports.dnsOverHTTPS.value}" = { };
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

      services.nginx.streamConfig = ''
        upstream dns_servers {
          server localhost:53;
        }

        server {
          listen 53 udp reuseport;
          proxy_timeout 20s;
          proxy_pass dns_servers;
        }
      '';
    })

    # Set up the firewall. Take note the ports with the transport layer being
    # accepted in Bind.
    (lib.mkIf hostCfg.services.firewall.enable {
      networking.firewall = {
        allowedUDPPorts = [ config.state.ports.dns.value ];
        allowedTCPPorts = with config.state.ports; [
          dns.value
          dnsOverHTTPS.value
          dnsOverTLS.value
        ];
      };
    })

    # Add the following to be backed up.
    (lib.mkIf hostCfg.services.backup.enable {
      services.borgbackup.jobs.services-backup.paths = [ zonesDir ];
    })

    # Set up a fail2ban which is apparently already available in the package.
    (lib.mkIf hostCfg.services.fail2ban.enable {
      services.fail2ban.jails."named-refused".settings = {
        enabled = true;
        backend = "systemd";
        filter = "named-refused[journalmatch='_SYSTEMD_UNIT=bind.service']";
        maxretry = 3;
      };
    })
  ]);
}
