{
  description = "foo-dogsquared's NixOS config as a flake";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters =
      "https://nix-community.cachix.org https://foo-dogsquared.cachix.org";
    extra-trusted-public-keys =
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E=";
  };

  inputs = {
    # I know NixOS can be stable but we're going cutting edge, baybee!
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # We're using this library for other functions, mainly testing.
    flake-utils.url = "github:numtide/flake-utils";

    # My personal dotfiles.
    dotfiles.url = "github:foo-dogsquared/dotfiles";
    dotfiles.flake = false;

    # Managing home configurations.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # This is what AUR strives to be.
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Running unpatched binaries on NixOS! :O
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    # Generate your NixOS systems to various formats!
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Managing your secrets.
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Easy access to development environments.
    devshell.url = "github:numtide/devshell";

    # We're getting more unstable there should be a black hole at my home right now.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # Guix in NixOS?!
    guix-overlay.url = "github:foo-dogsquared/nix-overlay-guix";
    guix-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # The more recommended Rust overlay so I'm going with it.
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # Generating an entire flavored themes with Nix?
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      # The order here is important(?).
      overlays = [
        # Put my custom packages to be available.
        (self: super: import ./pkgs { pkgs = super; })

        # Neovim nightly!
        inputs.neovim-nightly-overlay.overlay

        # Emacs unstable version!
        inputs.emacs-overlay.overlay

        # Rust overlay for them ease of setting up Rust toolchains.
        inputs.rust-overlay.overlays.default

        # Access to NUR.
        inputs.nur.overlay
      ];

      defaultSystem = inputs.flake-utils.lib.system.x86_64-linux;
      systems = with inputs.flake-utils.lib.system; [ x86_64-linux ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # We're considering this as the variant since we'll export the custom
      # library as `lib` in the output attribute.
      lib' = nixpkgs.lib.extend (final: prev:
        import ./lib { lib = prev; }
        // import ./lib/private.nix { lib = final; });

      mkHost = { system ? defaultSystem, extraModules ? [ ] }:
        (lib'.makeOverridable inputs.nixpkgs.lib.nixosSystem) {
          # The system of the NixOS system.
          inherit system;
          lib = lib';
          specialArgs = { inherit system inputs self; };
          modules =
            # Append with our custom NixOS modules from the modules folder.
            (lib'.modulesToList (lib'.filesToAttr ./modules/nixos))

            # Our own modules.
            ++ extraModules;
        };

      # The default configuration for our NixOS systems.
      hostDefaultConfig = { pkgs, system, ... }: {
        # Only use imports as minimally as possible with the absolute
        # requirements of a host.
        imports = [
          inputs.agenix.nixosModules.age
          inputs.home-manager.nixosModules.home-manager
          inputs.nix-ld.nixosModules.nix-ld
          inputs.nur.nixosModules.nur
        ];

        # Bleeding edge, baybee!
        nix.package = pkgs.nixUnstable;

        # I want to capture the usual flakes to its exact version so we're
        # making them available to our system. This will also prevent the
        # annoying downloads since it always get the latest revision.
        nix.registry = {
          # I'm narcissistic so I want my config to be one of the flakes in the
          # registry.
          config.flake = self;

          # All of the important flakes will be included.
          nixpkgs.flake = nixpkgs;
          home-manager.flake = inputs.home-manager;
          agenix.flake = inputs.agenix;
          nur.flake = inputs.nur;
          guix-overlay.flake = inputs.guix-overlay;
          nixos-generators.flake = inputs.nixos-generators;
        };

        # Set several binary caches.
        nix.settings = {
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://foo-dogsquared.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E="
          ];
        };

        nixpkgs.config.permittedInsecurePackages =
          [ "python3.10-django-3.1.14" ];

        # Set several paths for the traditional channels.
        nix.nixPath = [
          "nixpkgs=${nixpkgs}"
          "home-manager=${inputs.home-manager}"
          "nur=${inputs.nur}"
          "config=${self}"
          "/nix/var/nix/profiles/per-user/root/channels"
        ];

        # Stallman-senpai will be disappointed.
        nixpkgs.config.allowUnfree = true;

        # Extend nixpkgs with our overlays except for the NixOS-focused modules
        # here.
        nixpkgs.overlays = overlays
          ++ [ inputs.nix-alien.overlay inputs.guix-overlay.overlays.default ];

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

        # The global configuration for the home-manager module.
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
        home-manager.sharedModules =
          lib'.modulesToList (lib'.filesToAttr ./modules/home-manager);
        home-manager.extraSpecialArgs = { inherit inputs system self; };

        # Enabling some things for agenix.
        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
        services.sshd.enable = true;
        services.openssh.enable = true;
      };

      mkUser = { system ? defaultSystem, extraModules ? [ ] }:
        inputs.home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = { inherit system self inputs; };
          lib = lib';
          pkgs = nixpkgs.legacyPackages.${system};
          modules =
            # Importing our custom home-manager modules.
            (lib'.modulesToList (lib'.filesToAttr ./modules/home-manager))

            # Plus our own.
            ++ extraModules;
        };

      # The default config for our home-manager configurations.
      userDefaultConfig = { pkgs, ... }: {
        # To be able to use the most of our config as possible, we want both to
        # use the same overlays.
        nixpkgs.overlays = overlays;

        # Stallman-senpai will be disappointed. :(
        nixpkgs.config.allowUnfree = true;

        manual = {
          html.enable = true;
          json.enable = true;
          manpages.enable = true;
        };
      };

    in {
      # Exposes only my library with the custom functions to make it easier to
      # include in other flakes for whatever reason may be.
      lib = import ./lib { lib = nixpkgs.lib; };

      # A list of NixOS configurations from the `./hosts` folder. It also has
      # some sensible default configurations.
      nixosConfigurations = lib'.mapAttrsRecursive (host: path:
        let
          extraModules = [
            { networking.hostName = builtins.baseNameOf path; }
            hostDefaultConfig
            path
          ];
        in mkHost { inherit extraModules; }) (lib'.filesToAttr ./hosts);

      # We're going to make our custom modules available for our flake. Whether
      # or not this is a good thing is debatable, I just want to test it.
      nixosModules = lib'.importModules (lib'.filesToAttr ./modules/nixos);

      # I can now install home-manager users in non-NixOS systems.
      # NICE!
      homeManagerConfigurations = lib'.mapAttrs (_: path:
        let
          extraModules = [
            ({ pkgs, config, ... }: {
              home.username = builtins.baseNameOf path;
              home.homeDirectory = "/home/${config.home.username}";
            })
            userDefaultConfig
            path
          ];
        in mkUser { inherit extraModules; })
        (lib'.filesToAttr ./users/home-manager);

      # Extending home-manager with my custom modules, if anyone cares.
      homeManagerModules = lib'.importModules (lib'.filesToAttr ./modules/home-manager);

      # In case somebody wants to use my stuff to be included in nixpkgs.
      overlays.default = final: prev: import ./pkgs { pkgs = prev; };

      # My custom packages, available in here as well. Though, I mainly support
      # "x86_64-linux". I just want to try out supporting other systems.
      packages = forAllSystems (system:
        inputs.flake-utils.lib.flattenTree (import ./pkgs {
          pkgs = import nixpkgs { inherit system overlays; };
        }));

      # My several development shells for usual type of projects. This is much
      # more preferable than installing all of the packages at the system
      # configuration (or even home environment).
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in {
          default = import ./shell.nix { inherit pkgs; };
        } // (import ./shells { inherit pkgs; }));

      # Cookiecutter templates for your mama.
      templates = {
        default = self.templates.basic-devshell;
        basic-devshell = {
          path = ./templates/basic-devshell;
          description = "Basic development shell template";
        };
      };
    };
}
