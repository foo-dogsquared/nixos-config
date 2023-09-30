{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

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

  # Get the latest kernel for the desktop experience.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Adding a bunch of emulated systems for cross-system building.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  # Wanna be a wannabe haxxor, kid?
  programs.wireshark.package = pkgs.wireshark;

  # We're using some better filesystems so we're using it.
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [
      "/mnt/archives"
    ];
  };

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
    (swh.swh-core.overrideAttrs (attrs: {
      pythonPath = with pkgs.swh; [
        swh-model
        swh-fuse
      ];
    }))

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  services.auto-cpufreq.enable = true;
  services.avahi.enable = true;

  # We'll go with a software firewall. We're mostly configuring it as if we're
  # using a server even though the chances of that is pretty slim.
  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # Secure Shells.
      ];
    };
  };

  services.resolved.domains = [
    "~plover.foodogsquared.one"
    "~0.27.172.in-addr.arpa"
    "~0.28.172.in-addr.arpa"
  ];

  system.stateVersion = "23.11"; # Yes! I read the comment!
}
