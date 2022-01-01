{
  description = "foo-dogsquared's NixOS config as a flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # We're using this library for other functions, mainly testing.
    flake-utils.url = "github:numtide/flake-utils";

    # Managing home configurations.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Managing your secrets.
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Easy access to development environments.
    devshell.url = "github:numtide/devshell";

    # Overlays.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      overlays = [
        # Put my custom packages to be available.
        (self: super: import ./pkgs { pkgs = super; })

        # Neovim nightly!
        inputs.neovim-nightly-overlay.overlay

        # Rust overlay for them ease of setting up Rust toolchains.
        inputs.rust-overlay.overlay
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs inputs.flake-utils.lib.defaultSystems
        (system: f system);

      libExtended = nixpkgs.lib.extend (final: prev:
        (import ./lib { lib = final; }) // {
          flakeUtils = (import ./lib/flake-utils.nix {
            inherit inputs;
            lib = final;
          });
        });

      # The default configuration for our NixOS systems.
      hostDefaultConfig = {
        # I want to capture the usual flakes to its exact version so we're
        # making them available to our system. This will also prevent the
        # annoying downloads since it always get the latest revision.
        nix.registry = {
          # I'm narcissistic so I want my config to be one of the flakes in the registry.
          config.flake = self;

          # All of the important flakes will be included.
          nixpkgs.flake = nixpkgs;
          home-manager.flake = home-manager;
          agenix.flake = inputs.agenix;
        };

        # Stallman-senpai will be disappointed.
        nixpkgs.config.allowUnfree = true;

        # Extend nixpkgs with our own package set.
        nixpkgs.overlays = overlays;

        # Please clean your temporary crap.
        boot.cleanTmpDir = true;

        # We live in a Unicode world and dominantly English in technical fields so we'll
        # have to go with it.
        i18n.defaultLocale = "en_US.UTF-8";

        # Sane config for the package manager.
        # TODO: Remove this after nix-command and flakes has been considered stable.
        #
        # Since we're using flakes to make this possible, we need it. Plus, the
        # UX of Nix CLI is becoming closer to Guix's which is a nice bonus.
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };

      # The default config for our home-manager configurations.
      userDefaultConfig = {
        system = "x86_64-linux";

        # To be able to use the most of our config as possible, we want both to
        # use the same overlays.
        nixpkgs.overlays = overlays;

        # Stallman-senpai will be disappointed. :(
        nixpkgs.config.allowUnfree = true;

        # Let home-manager to manage itself.
        programs.home-manager.enable = true;
      };
    in {
      # Exposes only my library with the custom functions to make it easier to
      # include in other flakes.
      lib = import ./lib {
        inherit inputs;
        lib = nixpkgs.lib;
      };

      # A list of NixOS configurations from the `./hosts` folder. It also has
      # some sensible default configurations.
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

      # My custom packages, available in here as well. Though, I mainly support
      # "x86_64-linux". I just want to try out supporting other systems.
      packages = forAllSystems
        (system: import ./pkgs { pkgs = import nixpkgs { inherit system; }; });

      # The development environment for this flake.
      devShell = forAllSystems (system:
        import ./shell.nix { pkgs = import nixpkgs { inherit system; }; });

      # My several development shells for usual type of projects. This is much
      # more preferable than installing all of the packages at the system
      # configuration (or even home environment).
      devShells = forAllSystems (system:
        import ./shells {
          pkgs = import nixpkgs { inherit system overlays; };
        });
    };
}
