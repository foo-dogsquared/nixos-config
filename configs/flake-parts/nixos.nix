{ inputs

, defaultExtraArgs
, defaultNixConf

, ...
}:

{
  setups.nixos = {
    configs = {
      # The main desktop.
      ni = {
        systems = [ "x86_64-linux" ];
        formats = null;
        homeManagerUsers = {
          nixpkgsInstance = "global";
          users.foo-dogsquared = {
            userConfig = {
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
              description = "Gabriel Arazas";
            };
          };
        };
      };

      # A remote server.
      plover = {
        systems = [ "x86_64-linux" ];
        formats = null;
        domain = "foodogsquared.one";
        deploy = {
          hostname = "plover.foodogsquared.one";
          autoRollback = true;
          magicRollback = true;
        };
      };

      # TODO: Remove extra newlines that are here for whatever reason.
      #{{{
      void = {
        systems = [ "x86_64-linux" ];
        formats = [ "vm" ];
      };
      #}}}

      # The barely customized non-graphical installer.
      bootstrap = {
        systems = [ "aarch64-linux" "x86_64-linux" ];
        formats = [ "install-iso" ];
        nixpkgsBranch = "nixos-unstable-small";
      };

      # The barely customized graphical installer.
      graphical-installer = {
        systems = [ "aarch64-linux" "x86_64-linux" ];
        formats = [ "install-iso" ];
      };

      # The WSL system (that is yet to be used).
      winnowing = {
        systems = [ "x86_64-linux" ];
        formats = null;
        overlays = [
          inputs.neovim-nightly-overlay.overlays.default
        ];
        modules = [
          # Well, well, well...
          inputs.nixos-wsl.nixosModules.default
        ];
      };
    };

    # Only use imports as minimally as possible with the absolute
    # requirements of a host. On second thought, only on flakes with
    # optional NixOS modules.
    sharedModules = [
      # Import our custom modules.
      ../../modules/nixos
      ../../modules/nixos/_private

      inputs.nix-index-database.nixosModules.nix-index
      inputs.sops-nix.nixosModules.sops
      inputs.disko.nixosModules.disko

      defaultNixConf

      # The default shared configuration for the entire list of hosts for
      # this cluster. Take note to only set as minimal configuration as
      # possible since we're also using this with the stable version of
      # nixpkgs.
      ({ options, config, lib, pkgs, ... }: {
        # Initialize some of the XDG base directories ourselves since it is
        # used by NIX_PROFILES to properly link some of them.
        environment.sessionVariables = {
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_STATE_HOME = "$HOME/.local/state";
        };

        _module.args = defaultExtraArgs;

        # Find Nix files with these! Even if nix-index is already enabled, it
        # is better to make it explicit.
        programs.command-not-found.enable = false;
        programs.nix-index.enable = true;

        # BOOOOOOOOOOOOO! Somebody give me a tomato!
        services.xserver.excludePackages = with pkgs; [ xterm ];

        # Append with the default time servers. It is becoming more unresponsive as
        # of 2023-10-28.
        networking.timeServers = [
          "europe.pool.ntp.org"
          "asia.pool.ntp.org"
          "time.cloudflare.com"
        ] ++ options.networking.timeServers.default;

        # Disable channel state files. This shouldn't break any existing
        # programs as long as we manage them NIX_PATH ourselves.
        nix.channel.enable = lib.mkDefault false;

        # Set several paths for the traditional channels.
        nix.nixPath = lib.mkIf config.nix.channel.enable
          (lib.mapAttrsToList
            (name: source:
              let
                name' = if (name == "self") then "config" else name;
              in
              "${name'}=${source}")
            inputs
          ++ [
            "/nix/var/nix/profiles/per-user/root/channels"
          ]);

        # Please clean your temporary crap.
        boot.tmp.cleanOnBoot = lib.mkDefault true;

        # We live in a Unicode world and dominantly English in technical fields so we'll
        # have to go with it.
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

        # Enabling some things for sops.
        programs.gnupg.agent = lib.mkDefault {
          enable = true;
          enableSSHSupport = true;
        };
        services.openssh.enable = lib.mkDefault true;

        # It's following the 'nixpkgs' flake input which should be in unstable
        # branches. Not to mention, most of the system configurations should
        # have this attribute set explicitly by default.
        system.stateVersion = lib.mkDefault "23.11";
      })
    ];
  };

  flake = {
    # Listing my public NixOS modules if anyone cares.
    nixosModules.default = ../../modules/nixos;
  };
}
