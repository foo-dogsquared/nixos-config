# My NixOS config...
# This is where the specific setup go from setting environment variables, specific aliases, installing specific packages (e.g., muh games), and so forth.
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = import ./modules/overlays.nix;

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
        jupyter.enable = true;
        latex.enable = true;
      };
      game-dev = {
        godot.enable = true;
        unity3d.enable = true;
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
  ];

  my.packages = with pkgs; [
    # Muh games.
    unstable.dwarf-fortress      # Losing is fun!
    unstable.endless-sky         # Losing is meh!
    unstable.minetest            # Losing?! What's that?
    unstable.openmw              # Losing is even more meh1
    unstable.wesnoth             # Losing is frustrating!
    unstable.zeroad              # Losing is fun and frustrating!

    # Installing some of the dependencies required for my scripts.
    ffcast
    giflib
    leptonica
    libpng
    libwebp
    maim
    (tesseract.override { enableLanguages = [ "eng" ]; })
    slop
    xdg-user-dirs
    zbar
  ];

  # Setting up the shell environment.
  my.env = {
    BROWSER = "firefox";
    FILE = "lf";
    READ = "zathura";
    SUDO_ASKPASS = <config/bin/askpass>;
  };
  my.alias.dots = "USER=${config.my.username} make -C /etc/dotfiles";

  # Set your time zone.
  time.timeZone = "Asia/Manila";
  services.openssh.enable = true;
  services.lorri.enable = true;

  # Setup GnuPG.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # Install a proprietary Nvidia graphics driver.
  services.xserver.videoDrivers = [ "nvidiaLegacy390" ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Additional host-specific program configurations.
  my.home.programs = {
    # My personal Git config.
    git = {
      enable = true;

      # Enable Large File Storage.
      lfs.enable = true;

      # Use the entire suite.
      package = pkgs.gitAndTools.gitFull;

      userName = "Gabriel Arazas";
      userEmail = "${config.my.email}";
    };
  };

  # Moving all of the host-specific configurations into its appropriate place.
  my.home.xdg.dataFile =
    let insertXDGDataFolder = name: {
      source = ./config + "/${name}";
      recursive = true;
    }; in {
      "recoll" = insertXDGDataFolder "recoll";
      "unison" = insertXDGDataFolder "unison";
  };
}
