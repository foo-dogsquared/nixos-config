{ config, lib, pkgs, foodogsquaredLib, foodogsquaredUtils
, foodogsquaredModulesPath, ... }:

{
  imports = [
    # The users for this host.
    (foodogsquaredUtils.getUser "nixos" "admin")
    (foodogsquaredUtils.getUser "nixos" "plover")

    "${foodogsquaredModulesPath}/profiles/hardened.nix"
    "${foodogsquaredModulesPath}/profiles/hetzner-cloud-cx22.nix"

    ./disko.nix

    ./modules
  ];

  boot.supportedFilesystems = [ "btrfs" ];

  # Host-specific modules structuring.
  hosts.plover.services = {
    networking = {
      enable = true;
      macAddress = "96:00:03:c3:99:93";
    };

    backup.enable = true;
    database.enable = true;
    firewall.enable = true;
    idm.enable = true;
    monitoring.enable = true;
    reverse-proxy.enable = true;
    fail2ban.enable = true;
    grafana.enable = true;

    # All of the self-hosted applications belong in here.
    gitea.enable = true;
    vaultwarden.enable = true;
  };

  # Overriding the kernel version for ourselves.
  boot.kernelPackages =
    lib.mkOverride 500 pkgs.linuxKernel.packages.linux_6_11_hardened;

  # We're using our own VPN configuration for this one.
  suites.vpn.personal.enable = true;
  services.tailscale.useRoutingFeatures = "server";
  services.tailscaleAuth.enable = true;

  # Post installation script to be executed manually by the provisioner.
  system.build.postInstallationScript = pkgs.writeShellApplication {
    name = "post-installation-script";
    runtimeInputs = with pkgs; [ openssh ];
    text = ''
      sopsPrivateKey="''${1:-"key.txt"}"
      sopsKeyfileDir="$(dirname ${lib.escapeShellArg config.sops.age.keyFile})"
      mkdir -p "$sopsKeyfileDir" && mv "$sopsPrivateKey" "$sopsKeyfileDir"
    '';
  };

  state.network = rec {
    ipv4 = "135.181.26.192";
    ipv6 = "2a01:4f9:c010:8db4::1";

    interfaces = {
      lan = {
        ifname = "enp7s0";
        ipv4 = "10.0.0.2";
        ipv6 = "fe80::8400:ff:fef7:864";
        ipv4Gateway = "10.0.0.1";
        ipv6Gateway = "fe80::1";
      };

      wan = {
        ifname = "enp1s0";
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
      "213.133.100.103"
      "2a01:4f8:0:1::5ddc:2"

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
    dnsProvider = "hetzner";
    environmentFile =
      config.sops.secrets."lego/env".path or "/var/lib/secrets/acme.env";
    enableDebugLogs = true;
  };

  # Enable generating new DH params.
  security.dhparams.enable = true;

  # !!! The keys should be rotated at an interval here.
  services.openssh.hostKeys = lib.singleton {
    path = config.sops.secrets."ssh-key".path;
    type = "ed25519";
  };

  system.stateVersion = "24.11";
}
