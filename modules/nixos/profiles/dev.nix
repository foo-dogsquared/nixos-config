# The module for anything dev-related.
{ config, options, lib, pkgs, ... }:

let cfg = config.profiles.dev;
in {
  options.profiles.dev = {
    enable = lib.mkEnableOption
      "configurations of foo-dogsquared's barebones requirement for a development environment.";
    shell.enable = lib.mkEnableOption
      "installation of the shell utilities foo-dogsquared rely on";
    virtualization.enable =
      lib.mkEnableOption "virtualization-related stuff for development";
    neovim.enable = lib.mkEnableOption "Neovim setup";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
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
        config.difftool.prompt = false;

        # Yeah, let's use this oversized diff tool, shall we?
        # Also, this config is based from this tip.
        # https://lists.reproducible-builds.org/pipermail/diffoscope/2016-April/000193.html
        config.difftool."diffoscope".cmd = ''
          "if [ $LOCAL = /dev/null ]; then diffoscope --new-file $REMOTE; else diffoscope $LOCAL $REMOTE; fi"
        '';

        config.difftool."diffoscope-html".cmd = ''
          "if [ $LOCAL = /dev/null ]; then diffoscope --new-file $REMOTE --html - | cat; else diffoscope $LOCAL $REMOTE --html - | cat; fi"
        '';
      };

      # It's a given at life to have a GPG key.
      programs.gnupg.agent.enable = true;

      # Instrumentate your instrument.
      programs.systemtap.enable = true;

      # Search around sharks for wires.
      programs.wireshark.enable = true;

      # Profile your whole system.
      services.sysprof.enable = true;

      # Make shebangs even more magical.
      services.envfs.enable = true;

      # Convenience!
      environment.localBinInPath = true;

      # Find Nix files with these!
      programs.command-not-found.enable = false;
      programs.nix-index.enable = true;

      # Additional settings for developing with nix.
      nix.settings = {
        keep-outputs = true;
        keep-derivations = true;
      };

      # This is set as our system packages for the sake of convenience.
      services.lorri.enable = true;
      environment.systemPackages = with pkgs; [
        bind.dnsutils # A bunch of things to make sense with DNS.
        cachix # Compile no more by using someone's binary cache!
        curl # Our favorite network client.
        cmake # The poster boy for the hated build system.
        diffoscope # Oversized caffeine grinder.
        direnv # The power of local development environment.
        ipcalc # Calculate your IP without going to the web.
        lsof # View every single open connections.
        gcc # The usual toolchain.
        gdb # The usual debugger.
        gnumake # The other poster boy for the hated build system.
        man-pages # Extra manpages.
        moreutils # Less is more but more utilities, the merrier.
        whois # Doctor, are you not?
        valgrind # Making sure your applications don't pee as much.
      ]
      # Finally, a local environment for testing out GitHub workflows without
      # embarassing yourself pushing a bunch of commits.
      ++ (lib.optional config.virtualisation.docker.enable pkgs.act)

      # Enable all of the gud things.
      ++ (lib.optionals config.programs.git.enable [
        tea # Make some Tea...
        hut # ...in the Hut...
        github-cli # ...in the GitHub CLI.
        git-filter-repo # History is written by the victors (and force-pushers which are surely not victors).
      ]);
    })

    (lib.mkIf cfg.shell.enable {
      environment.systemPackages = with pkgs; [
        bandwhich # Sniffing your packets.
        lazygit # Git interface for the lazy.
        lazydocker # Git interface for the lazy.
        fd # Oh nice, a more reliable `find`.
        ripgrep # On nice, a more reliable `grep`.
        exa # Oh nice, a shinier `ls`.
        bat # dog > sky dog > cat
        fzf # A fuzzy finder that enables fuzzy finding not furry finding, a common misconception.
        gopass # An improved version of the password manager for hipsters.
        zoxide # Gain teleportation abilities!
      ];
    })

    # !!! Please add your user to the "libvirtd" group.
    (lib.mkIf cfg.virtualization.enable {
      environment.systemPackages = with pkgs; [
        distrobox # I heard you like Linux...
        virt-manager # An interface for those who are lazy to read a reference manual and create a 1000-line configuration per machine.
      ];

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
          "quay.io"
          "registry.opensuse.org"
        ];
      };

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

        # I want the BLEEDING EDGE!
        package = pkgs.neovim-nightly;
      };

      environment.systemPackages = with pkgs; [
        editorconfig-core-c # Consistent canonical coding conventions.
        tree-sitter # It surely doesn't have a partner to kiss.
      ];
    })
  ]);
}
