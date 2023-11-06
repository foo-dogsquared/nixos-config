{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./modules/networking.nix
    ./modules/wireguard.nix

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

  # My portable music streaming server.
  services.gonic = {
    enable = true;
    settings = {
      listen-addr = "127.0.0.1:4747";
      cache-path = "/var/cache/gonic";
      music-path = [
        "/srv/music"
      ];
      podcast-path = "/var/cache/gonic/podcasts";

      jukebox-enabled = true;

      scan-interval = 1;
      scan-at-start-enabled = true;
    };
  };

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
    i18n.enable = true;
    archiving.enable = true;
    browsers.chromium.enable = true;
    desktop = {
      enable = true;
      audio.enable = true;
      fonts.enable = true;
      hardware.enable = true;
      cleanup.enable = true;
      wine.enable = true;
    };
    dev = {
      enable = true;
      shell.enable = true;
      virtualization.enable = true;
      neovim.enable = true;
    };
    gaming = {
      enable = true;
      emulators.enable = true;
      retro-computing.enable = true;
    };
    filesystem = {
      tools.enable = true;
      setups.personal-webstorage.enable = true;
    };
    vpn.personal.enable = true;
  };

  # This is somewhat used for streaming games from it.
  programs.steam.remotePlay.openFirewall = true;

  programs.blender = {
    enable = true;
    package = pkgs.blender-with-packages {
      name = "foodogsquared-wrapped";
      packages = with pkgs.python3Packages; [ pandas ];
    };
    addons = with pkgs; [
      blender-blendergis
      blender-machin3tools
    ];
  };

  # Backup for the almighty archive, pls.
  tasks.backup-archive.enable = true;

  # The most extensible desktop environment with the greatest toolset of all
  # time (arguably but it is great).
  workflows.workflows.a-happy-gnome.enable = true;

  programs.wezterm.enable = true;
  programs.adb.enable = true;

  # Basically, the most basic nixpkgs configuration.
  environment.variables.NIXPKGS_CONFIG = lib.mkForce ./config/nixpkgs/config.nix;

  environment.systemPackages = with pkgs; [
    # Some sysadmin thingamajigs.
    openldap
    wireguard-tools

    # For debugging build environments in Nix packages.
    cntr

    # Searchsploit.
    exploitdb
  ];

  # Enable Guix service.
  services.guix.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Doxxing myself.
  location = {
    latitude = 15.0;
    longitude = 121.0;
  };

  system.stateVersion = "23.11"; # Yes! I read the comment!
}
