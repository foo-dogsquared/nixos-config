{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules

    (lib.mapHomeManagerUser "foo-dogsquared" {
      extraGroups = [
        "adbusers"
        "wheel"
        "audio"
        "docker"
        "podman"
        "networkmanager"
        "wireshark"
      ];
      hashedPassword =
        "$6$.cMYto0K0CHbpIMT$dRqyKs4q1ppzmTpdzy5FWP/V832a6X..FwM8CJ30ivK0nfLjQ7DubctxOZbeOtygfjcUd1PZ0nQoQpOg/WMvg.";
      isNormalUser = true;
      createHome = true;
      home = "/home/foo-dogsquared";
      description = "Gabriel Arazas";
    })
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

  sops.secrets = lib.getSecrets ./secrets/secrets.yaml {
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

  # Make Nix experimental.
  nix.package = pkgs.nixUnstable;

  # Some more experimentals for Nix.
  nix.settings.experimental-features = [ "auto-allocate-uids" "configurable-impure-env" ];

  # My poor achy-breaky desktop can't take it.
  nix.daemonCPUSchedPolicy = "idle";

  system.stateVersion = "24.05"; # Yes! I read the comment!
}
