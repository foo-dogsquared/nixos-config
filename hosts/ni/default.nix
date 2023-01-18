{ config, pkgs, lib, ... }:

let
  network = import ../plover/modules/hardware/networks.nix;
  inherit (network) publicIP wireguardIPv6BaseAddress wireguardPort;

  wireguardAllowedIPs = [ "0:0:0:0/0" "::/0" ];
  wireguardIFName = "wireguard0";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    (lib.mapHomeManagerUser "foo-dogsquared" {
      extraGroups = [
        "adbusers"
        "wheel"
        "audio"
        "docker"
        "podman"
        "networkmanager"
      ];
      hashedPassword =
        "$6$.cMYto0K0CHbpIMT$dRqyKs4q1ppzmTpdzy5FWP/V832a6X..FwM8CJ30ivK0nfLjQ7DubctxOZbeOtygfjcUd1PZ0nQoQpOg/WMvg.";
      isNormalUser = true;
      createHome = true;
      home = "/home/foo-dogsquared";
    })
  ];

  services.openssh.hostKeys = [{
    path = config.sops.secrets."ni/ssh-key".path;
    type = "ed25519";
  }];

  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ./secrets/secrets.yaml;
      };
      getSecrets = secrets:
        lib.mapAttrs'
          (secret: config:
            lib.nameValuePair
              "ni/${secret}"
              ((getKey secret) // config))
          secrets;
    in
    getSecrets {
      ssh-key = { };
      "ldap/password".owner = "nslcd";
      "wireguard/private-key" = {
        group = config.users.users.systemd-network.group;
        reloadUnits = [ "systemd-networkd.service" ];
        mode = "0640";
      };
      "wireguard/preshared-keys/plover" = {
        group = config.users.users.systemd-network.group;
        reloadUnits = [ "systemd-networkd.service" ];
        mode = "0640";
      };
      "wireguard/preshared-keys/phone" = {
        group = config.users.users.systemd-network.group;
        reloadUnits = [ "systemd-networkd.service" ];
        mode = "0640";
      };
    };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

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
    };
    dev = {
      enable = true;
      shell.enable = true;
      virtualization.enable = true;
      neovim.enable = true;
    };
  };

  tasks = {
    multimedia-archive.enable = true;
    backup-archive.enable = true;
  };
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

  environment.systemPackages = with pkgs; [
    openldap

    (swh.swh-core.overrideAttrs (super: self: {
      pythonPath = with swh; [
        swh-fuse
        swh-web-client
        swh-model
        swh-auth
      ];
    }))
  ];

  # Enable Guix service.
  services.guix.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    netbootxyz.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

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

  # The usual doas config.
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        persist = true;
      }

      # It is the primary user so we may as well just make this easier to run.
      {
        users = [ "foo-dogsquared" ];
        cmd = "nixos-rebuild";
        noPass = true;
      }
    ];
  };

  # We'll go with a software firewall. We're mostly configuring it as if we're
  # using a server even though the chances of that is pretty slim.
  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedUDPPorts = [ wireguardPort ];
      allowedTCPPorts = [
        22 # Secure Shells.

        80 # HTTP servers.
        433 # HTTPS servers.
      ];
    };
  };

  system.stateVersion = "22.11"; # Yes! I read the comment!

  # Trying to be very portable with LDAP.
  users.ldap = {
    enable = true;
    base = "dc=foodogsquared,dc=one";
    bind = {
      distinguishedName = "cn=Manager,dc=foodogsquared,dc=one";
      passwordFile = config.sops.secrets."ni/ldap/password".path;
    };

    daemon.enable = true;
    server = "ldaps://ldap.foodogsquared.one/";
  };

  # Setting up Wireguard as a VPN tunnel. Since this is a laptop that meant to
  # be used anywhere, we're configuring Wireguard here as a "client".
  #
  # We're also setting up this configuration as a forwarder
  systemd.network = {
    netdevs."99-${wireguardIFName}" = {
      netdevConfig = {
        Name = wireguardIFName;
        Kind = "wireguard";
      };

      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."ni/wireguard/private-key".path;
        ListenPort = wireguardPort;
      };

      wireguardPeers = [
        # Plover server peer. This is the main "server" of the network.
        {
          wireguardPeerConfig = {
            PublicKey = lib.readFile ../plover/files/wireguard/wireguard-public-key-plover;
            PresharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/plover".path;
            AllowedIPs = lib.concatStringsSep "," wireguardAllowedIPs;
            Endpoint = "${publicIP}:51820";
          };
        }

        # "Phone" peer. It is also expected to be anywhere on the global
        # network so we're basically setting up our own peer as a traffic
        # forwarder in case there's ever a reason to do connect from the phone
        # to the server which is always available anyways.
        {
          wireguardPeerConfig = {
            PublicKey = lib.readFile ../plover/files/wireguard/wireguard-public-key-phone;
            PresharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/phone".path;
            AllowedIPs = lib.concatStringsSep "," wireguardAllowedIPs;
            Endpoint = "${publicIP}:51820";
          };
        }
      ];
    };

    networks."99-${wireguardIFName}" = {
      matchConfig.Name = wireguardIFName;
      address = [
        "172.45.1.2/24"
        "${wireguardIPv6BaseAddress}/48"
      ];

      # Otherwise, it will autostart every bootup when I need it only at few
      # hours at a time.
      linkConfig.Unmanaged = true;
    };
  };
}
