# The module for anything dev-related.
{ config, lib, pkgs, ... }:

let cfg = config.profiles.dev;
in {
  options.profiles.dev = {
    enable = lib.mkEnableOption "basic configuration for software development";
    extras.enable = lib.mkEnableOption "additional shell utilities";
    containers.enable = lib.mkEnableOption "containers setup";
    virtual-machines.enable = lib.mkEnableOption "virtual machines setup";
    neovim.enable = lib.mkEnableOption "Neovim setup";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Hey! Wanna see some of <INSERT APPLICATION'S NAME> big dark dump?
      systemd.coredump = {
        enable = true;
        extraConfig = ''
          ProcessSizeMax=10G
          ExternalSizeMax=10G
        '';
      };

      # Debugging time!
      environment.enableDebugInfo = true;

      # I want to include documentations for my own sanity, OK?
      documentation = {
        enable = true;
        dev.enable = true;
        nixos.enable = true;
        man.generateCaches = true;
      };

      # Install Git, our favorite version control system.
      # In this case, we want ALL OF THE EXTENSIONS!
      programs.git = {
        enable = true;
        lfs.enable = true;
        package = pkgs.gitFull;
      };

      # It's a given at life to have a GPG key.
      programs.gnupg.agent.enable = true;

      # Instrumentate your instrument.
      programs.systemtap.enable = true;

      # Search around sharks for wires.
      programs.wireshark.enable = true;

      # Profile your whole system.
      services.sysprof.enable = true;

      # Additional settings for developing with nix.
      nix.settings = {
        keep-outputs = true;
        keep-derivations = true;
      };

      # This is set as our system packages for the sake of convenience.
      environment.systemPackages = with pkgs; [
        bind.dnsutils # A bunch of things to make sense with DNS.
        curl # Our favorite network client.
        ipcalc # Calculate your IP without going to the web.
        gcc # The usual toolchain.
        gdb # The usual debugger.
        gnumake # The other poster boy for the hated build system.
        moreutils # Less is more but more utilities, the merrier.
        sshfs # Make others' home your own.
        whois # Doctor, are you not?
        valgrind # Making sure your applications don't pee as much.

        # Measuring your bloated tanks power and bandwidth consumption.
        powertop
        nethogs

        # Hardware and software diagnostics.
        lsof # View every single open connections.
        lshw # View your hardware.
        pciutils # View your peripherals.

        # All of the documentation.
        man-pages # Extra manpages.
        man-pages-posix # More POSIX manpages.
      ];
    }

    (lib.mkIf cfg.extras.enable {
      environment.systemPackages = with pkgs; [
        bandwhich # Sniffing your packets.
        cachix # Compile no more by using someone's binary cache!
        direnv # The power of local development environment.
        lazygit # Git interface for the lazy.
        lazydocker # Git interface for the lazy.
        fd # Oh nice, a more reliable `find`.
        ripgrep # On nice, a more reliable `grep`.
        eza # Oh nice, a shinier `ls`.
        bat # dog > sky dog > cat
        fzf # A fuzzy finder that enables fuzzy finding not furry finding, a common misconception.
        quilt # Patching right up yer' alley.
        zoxide # Gain teleportation abilities!
      ]
      # Finally, a local environment for testing out GitHub workflows without
      # embarassing yourself pushing a bunch of commits.
      ++ (lib.optional config.virtualisation.docker.enable pkgs.act)

      # Enable all of the gud things.
      ++ (lib.optionals config.programs.git.enable (with pkgs; [
        tea # Make some Tea...
        hut # ...in the Hut...
        github-cli # ...in the GitHub CLI.
        git-filter-repo # History is written by the victors (and force-pushers which are surely not victors).
      ]));

      # Make per-project devenvs more of a living thing.
      services.lorri.enable = true;

      # Make shebangs even more magical.
      services.envfs.enable = true;

      # Convenience!
      environment.localBinInPath = true;
    })

    # !!! Please add your user to the "libvirtd" group.
    (lib.mkIf cfg.containers.enable {
      environment.systemPackages = with pkgs; [
        dive # Dive into container images.
      ];

      programs.distrobox = {
        enable = true;
        settings = {
          container_additional_volumes = [
            "/nix/store:/nix/store:r"
            "/etc/profiles/per-user:/etc/profiles/per-user:r"
          ];
          container_image_default = "registry.opensuse.org/opensuse/distrobox-packaging:latest";
          container_command = "sh -norc";
        };
      };

      # Podman with Docker compatibility which is not 100% but still better
      # than nothing.
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };

      # Enable usual containers configuration.
      virtualisation.containers = {
        enable = true;
        registries.search = [
          "docker.io"
          "ghcr.io"
          "quay.io"
          "registry.opensuse.org"
        ];
      };
    })

    (lib.mkIf cfg.virtual-machines.enable {
      environment.systemPackages = with pkgs; [
        virt-top # Monitoring your virtual machines on a terminal, yeah.
        virt-manager # An interface for those who are lazy to read a reference manual and create a 1000-line configuration per machine.
      ];

      # Virtual machines, son. They open in response to physical needs to
      # foreign environments.
      virtualisation.libvirtd = {
        enable = true;
        qemu.package = pkgs.qemu_full;
        qemu.ovmf.enable = true;
      };
    })

    (lib.mkIf cfg.neovim.enable {
      # Easier, better, faster, stronger.
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        withNodeJs = true;
        withRuby = true;
      };

      environment.systemPackages = with pkgs; [
        editorconfig-core-c # Consistent canonical coding conventions.
        tree-sitter # It surely doesn't have a partner to kiss.
      ];
    })
  ]);
}
