{ config, lib, pkgs, foodogsquaredLib, foodogsquaredUtils, foodogsquaredModulesPath, ... }:

{
  imports = [
    # Since this will be rarely configured, make sure to import the appropriate
    # hardware modules depending on the hosting provider (and even just the
    # server).
    ./modules/profiles/hetzner-cloud-cx21.nix

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
    # The essential services.
    backup.enable = true;
    database.enable = true;
    firewall.enable = true;
    dns-server.enable = true;
    idm.enable = true;
    monitoring.enable = true;
    reverse-proxy.enable = true;
    fail2ban.enable = true;

    # The self-hosted services.
    atuin.enable = true;
    gitea.enable = true;
    grafana.enable = true;
    vaultwarden.enable = true;
    wireguard.enable = true;
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
    credentialsFile = config.sops.secrets."lego/env".path;
  };

  # Enable generating new DH params.
  security.dhparams.enable = true;

  # !!! The keys should be rotated at an interval here.
  services.openssh.hostKeys = [{
    path = config.sops.secrets."ssh-key".path;
    type = "ed25519";
  }];

  # Make Nix experimental.
  nix.package = pkgs.nixUnstable;

  system.stateVersion = "23.05";
}
