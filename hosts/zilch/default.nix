# My NixOS config...
# This is where the specific setup go from setting environment variables, specific aliases, installing specific packages (e.g., muh games), and so forth.
{ config, pkgs, lib, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [ "spidermonkey-38.8.0" ];

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
  boot.kernelPackages = pkgs.linuxPackages_5_10;
  boot.extraModulePackages = [ pkgs.linuxPackages_5_10.nvidia_x11 ];

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
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = "$PATH:$XDG_BIN_HOME";
  };

  # Moving all of the host-specific configurations into its appropriate place.
  my.home.xdg.dataFile = let
    insertXDGDataFolder = name: {
      source = ./config + "/${name}";
      recursive = true;
    };
  in {
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
    docker = { enable = true; };

    libvirtd = { enable = true; };
  };

  # Enable some font configs.
  fonts = {
    enableDefaultFonts = true;
    fontconfig.enable = true;
  };

  location = {
    latitude = 15.0;
    longitude = 121.0;
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
      #cad.enable = true;
      fonts.enable = true;
      files.enable = true;
      graphics = {
        enable = true;
        raster.enable = true;
        vector.enable = true;
        _3d.enable = true;
      };
      multimedia.enable = true;
      research.enable = true;
      wine.enable = true;
    };

    dev = {
      android.enable = true;
      base.enable = true;
      cc.enable = true;
      data = {
        enable = true;
        #dhall.enable = true;
      };
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
      lisp = {
        clojure.enable = true;
        guile.enable = true;
        racket.enable = true;
      };
      math.enable = true;
      perl = {
        enable = true;
        raku.enable = true;
      };
      python = {
        enable = true;
        math.enable = true;
      };
      rust.enable = true;
      vcs.enable = true;
      web = {
        enable = true;
        javascript = {
          deno.enable = true;
          node.enable = true;
        };
        php.enable = true;
      };
    };

    hardware = {
      audio.enable = true;
      veikk.enable = true;
    };

    editors = {
      default = "nvim";
      emacs.enable = true;
      neovim.enable = true;
      vscode.enable = true;
    };

    services = { recoll.enable = true; };

    shell = {
      archiving.enable = true;
      base.enable = true;
      lf.enable = true;
      zsh.enable = true;
    };

    themes.fair-and-square.enable = true;
  };

  # Additional programs that doesn't need much configuration (or at least personally configured).
  # It is pointless to create modules for it, anyways.
  environment.systemPackages = with pkgs; [
    nim # Jack the nimble, jack jumped over the nightstick, and got over not being the best pick.
    python # *insert Monty Python quote here*
    ruby # Gems, lots of gems.
  ];

  my.packages = with pkgs;
    [
      # Muh games.
      dwarf-fortress # Losing is fun!
      endless-sky # Losing is meh!
      minetest # Losing?! What's that?
      the-powder-toy # Losing? The only thing losing is your time!
      wesnoth # Losing is frustrating!
      #zeroad # Losing is fun and frustrating!

      # Installing some of the dependencies required for my scripts.
      ffcast
      giflib
      imageworsener
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
      leocad
      screenkey
    ]

    # My custom packages.
    ++ (with pkgs.nur.foo-dogsquared; [
      flavours
      julia-bin
      hantemcli
      license-cli
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

  # Setup GnuPG.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # Install a proprietary Nvidia graphics driver.
  services = {
    xserver = {
      digimend.enable = true;
      libinput = {
        enable = true;
        middleEmulation = true;
      };
    };
    lorri.enable = true;
    nfs = {
      server = {
        enable = true;
        exports = ''
        /home 192.168.1.0/24(rw,sync,no_root_squash,no_subtree_check)
        '';
      };
    };
    openssh = {
      enable = true;
      permitRootLogin = "yes";
      extraConfig = ''
        PasswordAuthentication yes
      '';
      ports = [ 22664 ];
    };
    redshift.enable = true;
    # videoDrivers = [ "nvidiaLegacy390" ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable OpenGL.
  hardware = { opengl.enable = true; };

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

        # Enable Delta syntax highlighter.
        delta.enable = true;

        userName = "Gabriel Arazas";
        userEmail = "${config.my.email}";
      };

      # Enable this to make your prompt out of this world.
      starship = {
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enable = true;
      };
    };

    services = {
      unison = let
        homeDirectory = "/home/${config.my.username}";
        backupDrive =
          "/run/media/${config.my.username}/Seagate Backup Plus Drive";
      in {
        enable = true;
        pairs.mainBackup = {
          roots = [ homeDirectory backupDrive ];
          commandOptions = {
            auto = "true";
            batch = "true";
            dontchmod = "true";
            fat = "true";
            force = "${homeDirectory}";
            group = "true";
            links = "false";
            rsrc = "true";
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
  system.stateVersion = "20.09"; # Did you read the comment?
}
