# My NixOS config...
# This is where the specific setup go from setting environment variables, specific aliases, installing specific packages (e.g., muh games), and so forth.
{ config, pkgs, lib, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "spidermonkey-38.8.0"
  ];

  # Set the Nix package manager to use the unstable version for flakes.
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Change the Linux kernel version.
  boot.kernelPackages = pkgs.linuxPackages_5_8;
  boot.extraModulePackages = [ pkgs.linuxPackages_5_8.nvidia_x11 ];

  # Clean up the /tmp directory.
  boot.cleanTmpDir = true;

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

  # Moving all of the host-specific configurations into its appropriate place.
  my.home.xdg.dataFile =
    let insertXDGDataFolder = name: {
      source = ./config + "/${name}";
      recursive = true;
    }; in {
      "recoll" = insertXDGDataFolder "recoll";
      "unison" = insertXDGDataFolder "unison";
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

  # Enable some font configs.
  fonts = {
    enableDefaultFonts = true;
    fontconfig.enable = true;
  };

  # Module configurations.
  modules = {
    desktop = {
      audio = {
        enable = true;
        composition.enable = true;
        production.enable = true;
      };
      browsers = {
        brave.enable = true;
        firefox.enable = true;
        nyxt.enable = true;
      };
      cad.enable = true;
      fonts.enable = true;
      files.enable = true;
      graphics = {
        raster.enable = true;
        vector.enable = true;
        _3d.enable = true;
      };
      multimedia.enable = true;
      research.enable = true;
    };

    dev = {
      android.enable = true;
      base.enable = true;
      cc.enable = true;
      data.enable = true;
      documentation = {
        enable = true;
        latex.enable = true;
      };
      game-dev = {
        godot.enable = true;
        unity3d.enable = true;
      };
      go.enable = true;
      java.enable = true;
      javascript = {
        deno.enable = true;
        node.enable = true;
      };
      lisp = {
        guile.enable = true;
        racket.enable = true;
      };
      perl.enable = true;
      python = {
        enable = true;
        math.enable = true;
      };
      rust.enable = true;
      vcs.enable = true;
    };

    drivers = {
      veikk.enable = true;
    };

    editors = {
      default = "nvim";
      emacs.enable = true;
      neovim.enable = true;
      vscode.enable = true;
    };

    services = {
      recoll.enable = true;
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
    nim         # Jack the nimble, jack jumped over the nightstick, and got over not being the best pick.
    python      # *insert Monty Python quote here*
  ];

  my.packages = with pkgs; [
    # Muh games.
    dwarf-fortress      # Losing is fun!
    endless-sky         # Losing is meh!
    minetest            # Losing?! What's that?
    openmw              # Losing is even more meh1
    wesnoth             # Losing is frustrating!
    zeroad              # Losing is fun and frustrating!

    # Installing some of the dependencies required for my scripts.
    ffcast
    giflib
    leptonica
    libpng
    libwebp
    maim
    (tesseract.override { enableLanguages = [ "eng" ]; })
    slop
    virt-manager
    xclip
    xdg-user-dirs
    xorg.xwininfo
    zbar

    # Some other packages.
    screenkey
  ]

  # My custom packages.
  ++ (with pkgs.nur.foo-dogsquared; [
    segno
  ]);

  # Setting up the shell environment.
  my.env = {
    BROWSER = "firefox";
    FILE = "lf";
    READ = "zathura";
    SUDO_ASKPASS = <config/bin/askpass>;
  };

  # foo-dogsquared is my only alias.
  my.alias = {
    # Convenience alias for my NixOS config.
    dots = "USER=${config.my.username} make -C /etc/dotfiles";

    # Assume you've installed Doom Emacs.
    org-capture = "$XDG_CONFIG_HOME/emacs/bin/org-capture";
  };

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
  services.xserver = {
    libinput = {
      enable = true;
      middleEmulation = true;
    };
    # digimend.enable = true;
    # videoDrivers = [ "nvidiaLegacy390" ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable OpenGL.
  hardware = {
    opengl.enable = true;
  };

  # Additional host-specific program configurations.
  my.home = {
    programs = {
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

    services = {
      unison = let
        homeDirectory = "/home/${config.my.username}";
        backupDrive = "/run/media/${config.my.username}/Seagate Backup Plus Drive";
      in {
        enable = true;
        pairs.mainBackup = {
          roots = [ homeDirectory backupDrive ];
          commandOptions = {
            auto = "true";
            batch = "true";
            fat = "true";
            force = "${homeDirectory}";
            links = "false";
            ui = "text";
          };
        };
      };
    };
  };

  my.user.extraGroups = [ "docker" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
