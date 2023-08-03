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

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  programs.wireshark.package = pkgs.wireshark;

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
    desktop = {
      enable = true;
      audio.enable = true;
      fonts.enable = true;
      hardware.enable = true;
      cleanup.enable = true;
      autoUpgrade.enable = true;
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

  tasks.backup-archive.enable = true;
  workflows.workflows.a-happy-gnome.enable = true;

  programs.pop-launcher = {
    enable = true;
    plugins = with pkgs; [
      pop-launcher-plugin-duckduckgo-bangs
      pop-launcher-plugin-brightness
    ];
  };

  programs.wezterm.enable = true;
  programs.adb.enable = true;

  environment.etc."nix/nixpkgs-config.nix".source = pkgs.writeText "nixpkgs-config" ''
    {
      allowUnfree = true;
    }
  '';

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
  services.thermald.enable = true;
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
