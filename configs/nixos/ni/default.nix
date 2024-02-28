{ config, pkgs, lib, foodogsquaredLib, foodogsquaredModulesPath, ... }:

{
  imports = [
    "${foodogsquaredModulesPath}/profiles/desktop"

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Include the disko configuration.
    ./disko.nix

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

  # Enable the display manager of choice.
  services.xserver.displayManager.gdm.enable = true;

  # The keyfile required for the secrets to be decrypted.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # My custom configuration with my custom modules starts here.
  suites = {
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

  system.stateVersion = "24.05"; # Yes! I read the comment!
}
