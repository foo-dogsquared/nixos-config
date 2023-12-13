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
    networking.enable = true;
    networking.setup = "networkmanager";
    networking.wireguard.enable = true;
    setups.desktop.enable = true;
    setups.music.enable = true;
    setups.gaming.enable = true;
  };

  disko.devices = import ./disko.nix {
    disks = [ "/dev/nvme0n1" ];
  };

  services.openssh.hostKeys = [{
    path = config.sops.secrets."ssh-key".path;
    type = "ed25519";
  }];

  networking.timeServers = lib.mkBefore [
    "ntp.nict.jp"
    "time.nist.gov"
    "time.facebook.com"
  ];

  sops.secrets = lib.getSecrets ./secrets/secrets.yaml {
    "ssh-key" = { };
  };

  # The keyfile required for the secrets to be decrypted.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Adding a bunch of emulated systems for cross-system building.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  # My custom configuration with my custom modules starts here.
  profiles = {
    archiving.enable = true;
    browsers.chromium.enable = true;
    dev = {
      enable = true;
      shell.enable = true;
      virtualization.enable = true;
      neovim.enable = true;
    };
    filesystem = {
      tools.enable = true;
      setups.personal-webstorage.enable = true;
    };
  };

  # This is somewhat used for streaming games from it.
  programs.steam.remotePlay.openFirewall = true;

  programs.wezterm.enable = true;
  programs.adb.enable = true;

  # Basically, the most basic nixpkgs configuration.
  environment.variables.NIXPKGS_CONFIG = lib.mkForce ./config/nixpkgs/config.nix;

  environment.systemPackages = with pkgs; [
    # Some sysadmin thingamajigs.
    openldap

    # For debugging build environments in Nix packages.
    cntr

    # Searchsploit.
    exploitdb
  ];

  # Installing Guix within NixOS. Now that's some OTP rarepair material right
  # there.
  services.guix = {
    enable = true;
    gc = {
      enable = true;
      dates = "weekly";
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Doxxing myself.
  location = {
    latitude = 15.0;
    longitude = 121.0;
  };

  system.stateVersion = "24.05"; # Yes! I read the comment!
}
