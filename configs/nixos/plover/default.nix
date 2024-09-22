{ config, lib, pkgs, foodogsquaredLib, foodogsquaredUtils, foodogsquaredModulesPath, ... }:

{
  imports = [
    # Since this will be rarely configured, make sure to import the appropriate
    # hardware modules depending on the hosting provider (and even just the
    # server).
    ./modules/profiles/hetzner-cloud-cx22.nix

    # The users for this host.
    (foodogsquaredUtils.getUser "nixos" "admin")
    (foodogsquaredUtils.getUser "nixos" "plover")

    "${foodogsquaredModulesPath}/profiles/headless.nix"
    "${foodogsquaredModulesPath}/profiles/hardened.nix"

    ./disko.nix

    ./modules
  ];

  # Host-specific modules structuring.
  hosts.plover.services = {
    networking.enable = true;
    backup.enable = true;
    database.enable = true;
    firewall.enable = true;
    dns-server.enable = true;
    idm.enable = true;
    monitoring.enable = true;
    reverse-proxy.enable = true;
    fail2ban.enable = true;
    grafana.enable = true;
  };

  # We're using our own VPN configuration for this one.
  suites.vpn.personal.enable = true;

  state.network = rec {
    ipv4 = "135.181.26.192";
    ipv6 = "2a01:4f9:c011:b61e::1";

    interfaces = {
      lan = {
        ifname = "enp7s0";
        ipv4 = "10.0.0.2";
        ipv6 = "fe80::8400:ff:fef7:864";
        ipv4Gateway = "10.0.0.1";
        ipv6Gateway = "fe80::1";
      };

      wan = {
        ifname = "eth0";
        inherit ipv4 ipv6;
        ipv4Gateway = "172.31.1.1";
        ipv6Gateway = "fe80::1";
      };
    };

    secondaryNameservers = [
      # ns1.first-ns.de
      "213.239.242.238"
      "2a01:4f8:0:a101::a:1"

      # robotns2.second-ns.de
      "213.133.105.6"
      "2a01:4f8:d0a:2004::2"

      # robotns3.second-ns.com
      "193.47.99.3"
      "2001:67c:192c::add:a3"
    ];
  };

  state.paths = {
    dataDir = "/var/lib";
    cacheDir = "/var/cache";
    logDir = "/var/log";
    runtimeDir = "/run";
  };

  # Offline SSH!?!
  programs.mosh.enable = true;

  sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets/secrets.yaml {
    "ssh-key" = { };
    "lego/env" = { };
  };

  # All of the keys required to deploy the secrets.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  suites.server = {
    enable = true;
    cleanup.enable = true;
  };

  # DNS-related settings. We're settling by configuring the ACME setup with a
  # self-hosted DNS server.
  security.acme.defaults = {
    email = "admin+acme@foodogsquared.one";
    dnsProvider = "rfc2136";
    dnsResolver = "1.1.1.1";
    credentialsFile = config.sops.secrets."lego/env".path or "/var/lib/secrets/acme.env";
  };

  # Enable generating new DH params.
  security.dhparams.enable = true;

  # !!! The keys should be rotated at an interval here.
  services.openssh.hostKeys = [{
    path = config.sops.secrets."ssh-key".path;
    type = "ed25519";
  }];

  system.stateVersion = "24.11";
}
