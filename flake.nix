{
  description = "foo-dogsquared's NixOS config as a flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Overlays.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs,  ... }:
    let
      overlays = [
        # Put my custom packages to be available.
        (self: super: import ./pkgs { pkgs = super; })

        # Neovim nightly!
        inputs.neovim-nightly-overlay.overlay
      ];

      # All the target systems for my packages.
      systems = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      libExtended = nixpkgs.lib.extend (final: prev:
        (import ./lib {
          inherit inputs;
          lib = final;
        }));

      # The default configuration for our NixOS systems.
      hostDefaultConfig = {
        # Registering several registries.
        # I'm narcissistic so I want my config to be one of the flakes in the registry.
        nix.registry.config.flake = self;

        # This will also prevent the annoying downloads since it always get the latest revision.
        nix.registry.nixpkgs.flake = nixpkgs;

        # Stallman-senpai will be disappointed.
        nixpkgs.config.allowUnfree = true;

        # Extend nixpkgs with our own package set.
        nixpkgs.overlays = overlays;

        # We live in a Unicode world and dominantly English in technical fields so we'll
        # have to go with it.
        i18n.defaultLocale = "en_US.UTF-8";

        # Sane config for the package manager.
        nix.gc = {
          automatic = true;
          dates = "monthly";
          options = "--delete-older-than 2w";
        };

        # TODO: Remove this after nix-command and flakes has been considered stable.
        #
        # Since we're using flakes to make this possible, we need it.
        # Plus, the UX of Nix CLI is becoming closer to Guix's which is a nice bonus.
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };

      # The default config for our home-manager configurations.
      userDefaultConfig = {
        system = "x86_64-linux";

        # To be able to use the most of our config as possible, we want both to use the same overlays.
        nixpkgs.overlays = overlays;

        # Stallman-senpai will be disappointed. :(
        nixpkgs.config.allowUnfree = true;
      };
    in {
      # Exposes only my library with the custom functions to make it easier to include in other flakes.
      lib = import ./lib {
        inherit inputs;
        lib = nixpkgs.lib;
      };

      # A list of NixOS configurations from the `./hosts` folder.
      # It also has some sensible default configurations.
      nixosConfigurations = libExtended.mapAttrsRecursive
        (host: path: libExtended.flakeUtils.mkHost path hostDefaultConfig)
        (libExtended.filesToAttr ./hosts);

      # We're going to make our custom modules available for our flake. Whether
      # or not this is a good thing is debatable, I just want to test it.
      nixosModules = libExtended.mapAttrsRecursive (_: path: import path)
        (libExtended.filesToAttr ./modules/nixos);

      # I can now install home-manager users in non-NixOS systems.
      # NICE!
      homeManagerConfigurations = libExtended.mapAttrs
        (_: path: libExtended.flakeUtils.mkUser path userDefaultConfig)
        (libExtended.filesToAttr ./users/home-manager);

      # Extending home-manager with my custom modules, if anyone cares.
      homeManagerModules = libExtended.mapAttrsRecursive (_: path: import path)
        (libExtended.filesToAttr ./modules/home-manager);

      # My custom packages, available in here as well.
      # Though, I mainly support "x86_64-linux".
      # I just want to try out supporting other systems.
      packages = forAllSystems
        (system: import ./pkgs { pkgs = import nixpkgs { inherit system; }; });
    };
}
