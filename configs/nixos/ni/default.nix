{ config, pkgs, lib, foodogsquaredModulesPath, ... }:

{
  imports = [
    "${foodogsquaredModulesPath}/profiles/desktop"

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Include the disko configuration.
    ./disko.nix

    # My host-specific modules.
    ./modules
  ];

  hosts.ni = {
    hardware.qol.enable = true;
    networking.enable = true;
    services.backup.enable = true;
    services.monitoring.enable = true;
    services.mail-archive.enable = true;
    services.reverse-proxy.enable = true;
    services.download-media.enable = true;
    services.rss-reader.enable = true;
    services.dns-server.enable = true;
    setups = {
      desktop.enable = true;
      development.enable = true;
      music.enable = true;
      gaming.enable = true;
    };
  };

  state.paths = {
    cacheDir = "/var/cache";
    dataDir = "/var/lib";
    logDir = "/var/log";
    runtimeDir = "/run";
  };

  # Enable the display manager of choice.
  services.displayManager.gdm.enable = true;

  # The keyfile required for the secrets to be decrypted.
  sops.age.keyFile = "/var/lib/sops-nix/key";

  # Enable Nix channels.
  nix.channel.enable = true;

  # Make Nix experimental.
  nix.package = pkgs.nixStable;

  system.stateVersion = "24.05"; # Yes! I read the comment!
}
