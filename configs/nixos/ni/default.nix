{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules
  ];

  hosts.ni = {
    hardware.qol.enable = true;
    networking = {
      enable = true;
      wireguard.enable = true;
    };
    services.backup.enable = true;
    setups = {
      desktop.enable = true;
      development.enable = true;
      music.enable = true;
      gaming.enable = true;
    };
  };

  disko.devices = import ./disko.nix {
    disks = [ "/dev/nvme0n1" ];
  };

  services.openssh.hostKeys = [{
    path = config.sops.secrets."ssh-key".path;
    type = "ed25519";
  }];

  sops.secrets = lib.private.getSecrets ./secrets/secrets.yaml {
    "ssh-key" = { };
  };

  # The keyfile required for the secrets to be decrypted.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # My custom configuration with my custom modules starts here.
  profiles = {
    archiving.enable = true;
    browsers.chromium.enable = true;
    filesystem.setups.personal-webstorage.enable = true;
  };

  # Basically, the most basic nixpkgs configuration.
  environment.variables.NIXPKGS_CONFIG = lib.mkForce ./config/nixpkgs/config.nix;

  # Enable Nix channels.
  nix.channel.enable = true;

  # Make Nix experimental.
  nix.package = pkgs.nixStable;

  # Some more experimentals for Nix.
  nix.settings = {
    auto-allocate-uids = true;
    experimental-features = [ "auto-allocate-uids" ];
  };

  # My poor achy-breaky desktop can't take it.
  nix.daemonCPUSchedPolicy = "idle";

  system.stateVersion = "24.05"; # Yes! I read the comment!
}
