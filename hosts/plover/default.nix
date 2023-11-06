{ config, lib, pkgs, modulesPath, ... }:

let
  inherit (import ./modules/hardware/networks.nix) interfaces;
in
{
  imports = [
    # Since this will be rarely configured, make sure to import the appropriate
    # hardware modules depending on the hosting provider (and even just the
    # server).
    ./modules/hardware/hetzner-cloud-cx21.nix

    # The users for this host.
    (lib.getUser "nixos" "admin")
    (lib.getUser "nixos" "plover")

    # Hardened profile from nixpkgs.
    "${modulesPath}/profiles/hardened.nix"

    # Of course, what is a server without a backup? A professionally-handled
    # production system. However, we're not professionals so we do have
    # backups.
    ./modules/services/borgbackup.nix

    # The primary DNS server that is completely hidden.
    ./modules/services/bind.nix

    # The reverse proxy of choice.
    ./modules/services/nginx.nix

    # The single-sign on setup.
    ./modules/services/kanidm.nix
    ./modules/services/vouch-proxy.nix

    # The monitoring stack.
    ./modules/services/prometheus.nix
    ./modules/services/grafana.nix

    # The database of choice which is used by most self-managed services on
    # this server.
    ./modules/services/postgresql.nix

    # The application services for this server. They are modularized since
    # configuring it here will make it too big.
    ./modules/services/atuin.nix
    ./modules/services/gitea.nix
    ./modules/services/vaultwarden.nix
    ./modules/services/wireguard.nix
    ./modules/services/wezterm-mux-server.nix
  ];

  # Automatic format and partitioning.
  disko.devices = import ./disko.nix {
    disks = [ "/dev/sda" ];
  };

  networking = {
    nftables.enable = true;
    domain = "foodogsquared.one";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # Secure Shells.
      ];
    };
  };

  services.fail2ban = {
    ignoreIP = [
      # VPN clients.
      "${interfaces.wireguard0.IPv4.address}/13"
      "${interfaces.wireguard0.IPv6.address}/64"
    ];

    # We're going to be unforgiving with this one since we only have key
    # authentication and password authentication is disabled anyways.
    jails.sshd.settings = {
      enabled = true;
      maxretry = 1;
    };
  };


  sops.secrets = lib.getSecrets ./secrets/secrets.yaml {
    "ssh-key" = { };
    "lego/env" = { };
  };

  # All of the keys required to deploy the secrets.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  profiles.server = {
    enable = true;
    headless.enable = true;
    hardened-config.enable = true;
    cleanup.enable = true;
  };

  # DNS-related settings. We're settling by configuring the ACME setup with a
  # self-hosted DNS server.
  security.acme.defaults = {
    email = "admin+acme@foodogsquared.one";
    dnsProvider = "rfc2136";
    dnsResolver = "1.1.1.1";
    credentialsFile = config.sops.secrets."lego/env".path;
  };

  # Enable generating new DH params.
  security.dhparams.enable = true;

  # !!! The keys should be rotated at an interval here.
  services.openssh.hostKeys = [{
    path = config.sops.secrets."ssh-key".path;
    type = "ed25519";
  }];

  system.stateVersion = "23.11";
}
