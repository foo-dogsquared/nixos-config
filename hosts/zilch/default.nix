{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;

  # Enable XDG conventions.
  my.home.xdg.enable = true;
  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_BIN_HOME    = "$HOME/.local/bin";
  };

  # Install documentations for tools and whatnot.
  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
  };

  # Enable virutialization.
  virtualisation = {
    docker = {
      enable = true;
    };

    libvirtd = {
      enable = true;
    };
  };

  # Module configurations.
  modules = {
    desktop = {
      browsers = {
        brave.enable = true;
        firefox.enable = true;
      };
      fonts.enable = true;
      files.enable = true;
      graphics = {
        raster.enable = true;
        vector.enable = true;
        _3d.enable = true;
      };
      multimedia.enable = true;
      music = {
        composition.enable = true;
        production.enable = true;
      };
    };

    dev = {
      android.enable = true;
      base.enable = true;
      documentation = {
        enable = true;
        latex.enable = true;
      };
      java.enable = true;
      javascript = {
        deno.enable = true;
        node.enable = true;
      };
      lisp = {
        guile.enable = true;
        racket.enable = true;
      };
      rust.enable = true;
    };

    editors = {
      default = "nvim";
      emacs.enable = true;
      neovim.enable = true;
    };

    services = {
      recoll.enable = true;
      unison.enable = true;
    };

    shell = {
      base.enable = true;
      git.enable = true;
      lf.enable = true;
      zsh.enable = true;
    };

    themes.fair-and-square.enable = true;
  };

  # Additional programs that doesn't need much configuration (or at least personally configured).
  # It is pointless to create modules for it, anyways.
  environment.systemPackages = with pkgs; [
    # defold
    nim         # Jack the nimble, jack jumped over the nightstick, and got over not being the best pick.
    python      # *insert Monty Python quote here*

    # Muh games.
    zeroad
    wesnoth
  ];

  my.env = {
    BROWSER = "firefox";
    FILE = "lf";
    READ = "zathura";
    SUDO_ASKPASS = <config/bin/askpass>;
  };
  my.alias.dots = "USER=${config.my.username} make -C /etc/install";

  # Set your time zone.
  time.timeZone = "Asia/Manila";
  services.openssh.enable = true;
  services.lorri.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  my.home.programs = {
    # My personal Git config.
    git = {
      enable = true;

      # Enable the syntax highlighter with Delta.
      # https://github.com/dandavison/delta
      delta.enable = true;

      # Enable Large File Storage.
      lfs.enable = true;

      # Use the entire suite.
      package = pkgs.gitAndTools.gitFull;

      userName = "Gabriel Arazas";
      userEmail = "${config.my.email}";
    };
  };

  my.home.services = {
    # Unison backup strat.
    unison = {
      enable = true;

      pairs.mainbackup = 
        let
          homeDirectory = "/home/${config.my.username}";
          backupDrive = "/run/media/${config.my.username}/Seagate Backup Plus Drive";
        in {
        roots = [
          homeDirectory
          backupDrive
        ];
        commandOptions = {
          # Unison may delete the entire stuff so indicate that the other is a mount point.
          mountpoint = backupDrive;
          force = homeDirectory;

          # My GnuPG keys.
          path = ".gnupg .password-store";
        };
      };
    };
  };
}
