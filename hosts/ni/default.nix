# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # My custom configuration with my custom modules starts here.
  modules = {
    agenix.enable = true;
    archiving.enable = true;
    desktop = {
      enable = true;
      audio.enable = true;
    };
    dev = {
      enable = true;
      shell.enable = true;
    };
    editors = {
      emacs.enable = true;
      neovim.enable = true;
    };
    themes.a-happy-gnome.enable = true;
    users.users = [ "foo-dogsquared" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Doxxing myself.
  location = {
    latitude = 15.0;
    longitude = 121.0;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  hardware.opentabletdriver.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ git wget brave lf fd ripgrep ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # The usual doas config.
  security.doas = {
    enable = true;
    extraRules = [{
      groups = [ "wheel" ];
      persist = true;
    }];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # This is my external hard disk so it has to be non-blocking.
  fileSystems."/mnt/archive" = {
    device = "/dev/disk/by-uuid/665A391C5A38EB07";
    fsType = "ntfs";
    noCheck = true;
    options = [
      "nofail"
      "noauto"
      "user"
      "x.systemd.automount"
      "x.systemd.device.timeout=1ms"
    ];
  };

  # Automated backup for my external storage.
  services.borgbackup.jobs = {
    personal_archive = {
      exclude = [
        "/home/*/.cache"

        # The usual NodeJS shenanigans.
        "*/node_modules"
        "*/.next"

        # Rust-related files.
        "projects/software/*/result"
        "projects/software/*/build"
        "projects/software/*/target"
      ];
      doInit = false;
      removableDevice = true;
      repo = "/archive/backups";
      paths = [ "~/dotfiles" "~/library" "~/writings" ];
      encryption = {
        mode = "repokey";
        passCommand = "${pkgs.gopass}/bin/gopass show misc/BorgBackup_pass";
      };
      compression = "auto,lzma";
      startAt = "daily";
      prune = {
        prefix = "{hostname}-";
        keep = {
          within = "1d";
          daily = 30;
          weekly = 4;
          monthly = 6;
          yearly = 4;
        };
      };
    };
  };
}

