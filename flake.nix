{
  description = "foo-dogsquared's abomination of a NixOS configuration";

  nixConfig = {
    extra-substituters =
      "https://nix-community.cachix.org";
    extra-trusted-public-keys =
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };

  inputs = {
    # I know NixOS can be stable but we're going cutting edge, baybee! While
    # `nixpkgs-unstable` branch could be faster delivering updates, it is
    # looser when it comes to stability for the entirety of this configuration.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Here are the nixpkgs variants used for creating the system configuration
    # in `mkHost`.
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # We're using these libraries for other functions.
    flake-utils.url = "github:numtide/flake-utils";

    # Managing home configurations.
    home-manager.url = "github:nix-community/home-manager";

    # This is what AUR strives to be.
    nur.url = "github:nix-community/NUR";

    # Running unpatched binaries on NixOS! :O
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    # Generate your NixOS systems to various formats!
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Managing your secrets.
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Easy access to development environments.
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    # We're getting more unstable there should be a black hole at my home right
    # now. Also, we're seem to be collecting text editors like it is Pokemon.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";

    # Guix in NixOS?!
    guix-overlay.url = "github:foo-dogsquared/nix-overlay-guix";

    # The more recommended Rust overlay so I'm going with it.
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # Generating an entire flavored themes with Nix?
    nix-colors.url = "github:misterio77/nix-colors";

    # Removing the manual partitioning part with a little boogie.
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Deploying stuff with Nix. This is becoming a monorepo for everything I
    # need and I'm liking it.
    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixpkgs";

    # Someone has already solved downloading Firefox addons so we'll use it.
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      # A set of images with their metadata that is usually built for usual
      # purposes. The format used here is whatever formats nixos-generators
      # support.
      images = lib'.importTOML ./images.toml;

      # A set of users with their metadata to be deployed with home-manager.
      users = lib'.importTOML ./users.toml;

      # A set of image-related utilities for the flake outputs.
      inherit (import ./lib/images.nix { inherit inputs; lib = lib'; }) mkHost mkUser mkImage;

      # The order here is important(?).
      overlays = [
        # Put my custom packages to be available.
        self.overlays.default

        (final: prev: {
          inherit (inputs.firefox-addons.lib.${defaultSystem}) buildFirefoxXpiAddon;
          firefox-addons = final.callPackage ./pkgs/firefox-addons { };
        })

        # Neovim nightly!
        inputs.neovim-nightly-overlay.overlays.default

        # Emacs unstable version!
        inputs.emacs-overlay.overlays.default

        # Rust overlay for them ease of setting up Rust toolchains.
        inputs.rust-overlay.overlays.default

        # Access to NUR.
        inputs.nur.overlay
      ];

      defaultSystem = inputs.flake-utils.lib.system.x86_64-linux;

      # Just add systems here and it should add systems to the outputs.
      systems = with inputs.flake-utils.lib.system; [ defaultSystem ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      extraArgs = {
        inherit (inputs) nix-colors;
        inherit inputs;

        # This is a variable that is used to check whether the module is
        # exported or not. Useful for configuring parts of the configuration
        # that is otherwise that cannot be exported for others' use.
        #
        # "Fds" stands for foo-dogsquared just because. :p
        _isInsideFds = true;
      };

      # We're considering this as the variant since we'll export the custom
      # library as `lib` in the output attribute.
      lib' = nixpkgs.lib.extend (final: prev:
        import ./lib { lib = prev; }
        // import ./lib/private.nix { lib = final; });

      # The shared configuration for the entire list of hosts for this cluster.
      # Take note to only set as minimal configuration as possible since we're
      # also using this with the stable version of nixpkgs.
      hostSharedConfig = { config, lib, pkgs, ... }: {
        # Some defaults for evaluating modules.
        _module.check = true;

        # Only use imports as minimally as possible with the absolute
        # requirements of a host. On second thought, only on flakes with
        # optional NixOS modules.
        imports = [
          inputs.home-manager.nixosModules.home-manager
          inputs.nix-ld.nixosModules.nix-ld
          inputs.nur.nixosModules.nur
          inputs.sops-nix.nixosModules.sops
          inputs.guix-overlay.nixosModules.guix
          inputs.disko.nixosModules.disko
        ];

        # BOOOOOOOOOOOOO! Somebody give me a tomato!
        services.xserver.excludePackages = with pkgs; [ xterm ];

        # I want to capture the usual flakes to its exact version so we're
        # making them available to our system. This will also prevent the
        # annoying downloads since it always get the latest revision.
        nix.registry =
          lib.mapAttrs'
            (name: flake:
              let
                name' = if (name == "self") then "config" else name;
              in
              lib.nameValuePair name' { inherit flake; })
            inputs;

        # Set several paths for the traditional channels.
        nix.nixPath =
          lib.mapAttrsToList
            (name: source:
              let
                name' = if (name == "self") then "config" else name;
              in
              "${name'}=${source}")
            inputs
          ++ [
            "/nix/var/nix/profiles/per-user/root/channels"
          ];

        nix.settings = {
          # Set several binary caches.
          substituters = [
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          # Sane config for the package manager.
          # TODO: Remove this after nix-command and flakes has been considered stable.
          #
          # Since we're using flakes to make this possible, we need it. Plus, the
          # UX of Nix CLI is becoming closer to Guix's which is a nice bonus.
          experimental-features = [ "nix-command" "flakes" "repl-flake" ];
          auto-optimise-store = lib.mkDefault true;
        };

        # Stallman-senpai will be disappointed.
        nixpkgs.config.allowUnfree = true;

        # Extend nixpkgs with our overlays except for the NixOS-focused modules
        # here.
        nixpkgs.overlays = overlays;

        # Please clean your temporary crap.
        boot.tmp.cleanOnBoot = lib.mkDefault true;

        # We live in a Unicode world and dominantly English in technical fields so we'll
        # have to go with it.
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

        # The global configuration for the home-manager module.
        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
        home-manager.sharedModules =
          (import ./modules/home-manager {
            inherit lib;
            isInternal = true;
          })
          ++ [ userSharedConfig ];
        home-manager.extraSpecialArgs = extraArgs;

        # Enabling some things for sops.
        programs.gnupg.agent = lib.mkDefault {
          enable = true;
          enableSSHSupport = true;
        };
        services.openssh.enable = lib.mkDefault true;

        # We're setting Guix service package with the flake-provided package.
        # This is to prevent problems setting with overlays as much as I like
        # using them.
        services.guix.package = inputs.guix-overlay.packages.${config.nixpkgs.system}.guix;
      };

      # The default config for our home-manager configurations. This is also to
      # be used for sharing modules among home-manager users from NixOS
      # configurations with `nixpkgs.useGlobalPkgs` set to `true` so avoid
      # setting nixpkgs-related options here.
      userSharedConfig = { pkgs, config, ... }: {
        imports = [ inputs.nur.hmModules.nur ];

        # Hardcoding this is not really great especially if you consider using
        # other locales but its default values are already hardcoded so what
        # the hell. For other users, they would have to do set these manually.
        xdg.userDirs =
          let
            # The home directory-related options should be already taken care
            # of at this point. It is an ABSOLUTE MUST that it is set properly
            # since other parts of the home-manager config relies on it being
            # set properly.
            #
            # Here are some of the common cases for setting the home directory
            # options.
            #
            # * For exporting home-manager configurations, this is done in this
            #   flake definition.
            # * For NixOS configs, this is done automatically by the
            #   home-manager NixOS module.
            # * Otherwise, you'll have to manually set them.
            appendToHomeDir = path: "${config.home.homeDirectory}/${path}";
          in
          {
            desktop = appendToHomeDir "Desktop";
            documents = appendToHomeDir "Documents";
            download = appendToHomeDir "Downloads";
            music = appendToHomeDir "Music";
            pictures = appendToHomeDir "Pictures";
            publicShare = appendToHomeDir "Public";
            templates = appendToHomeDir "Templates";
            videos = appendToHomeDir "Videos";
          };

        programs.home-manager.enable = true;

        manual = {
          html.enable = true;
          json.enable = true;
          manpages.enable = true;
        };
      };
    in
    {
      # Exposes only my library with the custom functions to make it easier to
      # include in other flakes for whatever reason may be.
      lib = import ./lib { lib = nixpkgs.lib; };

      # A list of NixOS configurations from the `./hosts` folder. It also has
      # some sensible default configurations.
      nixosConfigurations = lib'.mapAttrs
        (host: metadata:
          let
            path = ./hosts/${host};
            extraModules = [
              ({ lib, ... }: {
                config = lib.mkMerge [
                  { networking.hostName = metadata.hostname or host; }

                  (lib.mkIf (metadata ? domain)
                    { networking.domain = metadata.domain; })
                ];
              })

              hostSharedConfig
              path
            ];
          in
          mkHost {
            inherit extraModules extraArgs;
            system = metadata.system or defaultSystem;
            nixpkgs-channel = metadata.nixpkgs-channel or "nixpkgs";
          })
        (lib'.filterAttrs (name: host: (host.format or "iso") == "iso") images);

      # We're going to make our custom modules available for our flake. Whether
      # or not this is a good thing is debatable, I just want to test it.
      nixosModules = lib'.importModules (lib'.filesToAttr ./modules/nixos);

      # I can now install home-manager users in non-NixOS systems.
      # NICE!
      homeConfigurations = lib'.mapAttrs
        (name: metadata:
          let
            system = metadata.system or defaultSystem;
            pkgs = import inputs."${metadata.nixpkgs-channel or "nixpkgs"}" {
              inherit system overlays;
            };
            path = ./users/home-manager/${name};
            extraModules = [
              ({ pkgs, config, ... }: {
                # To be able to use the most of our config as possible, we want
                # both to use the same overlays.
                nixpkgs.overlays = overlays;

                # Stallman-senpai will be disappointed. :/
                nixpkgs.config.allowUnfree = true;

                # Setting the homely options.
                home.username = metadata.username or name;
                home.homeDirectory = metadata.home-directory or "/home/${config.home.username}";
              })
              userSharedConfig
              path
            ];
          in
          mkUser {
            inherit pkgs system extraModules extraArgs;
            home-manager-channel = metadata.home-manager-channel or "home-manager";
          })
        users;

      # Extending home-manager with my custom modules, if anyone cares.
      homeModules =
        lib'.importModules (lib'.filesToAttr ./modules/home-manager);

      # In case somebody wants to use my stuff to be included in nixpkgs.
      overlays.default = final: prev: import ./pkgs { pkgs = prev; };

      # My custom packages, available in here as well. Though, I mainly support
      # "x86_64-linux". I just want to try out supporting other systems.
      packages = forAllSystems (system:
        inputs.flake-utils.lib.flattenTree (import ./pkgs {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                inherit (inputs.firefox-addons.lib.${system}) buildFirefoxXpiAddon;
              })
            ];
          };
        }));

      # This contains images that are meant to be built and distributed
      # somewhere else including those NixOS configurations that are built as
      # an ISO.
      images =
        lib'.mapAttrs
          (host: metadata:
            let
              system = metadata.system or defaultSystem;
              nixpkgs-channel = metadata.nixpkgs-channel or "nixpkgs";
              pkgs = import inputs."${nixpkgs-channel}" { inherit system overlays; };
              format = metadata.format or "iso";
            in
              mkImage {
                inherit format system pkgs extraArgs;
                extraModules = [
                  ({ lib, ... }: {
                    config = lib.mkMerge [
                      { networking.hostName = lib.mkForce metadata.hostname or host; }

                      (lib.mkIf (metadata ? domain)
                        { networking.domain = lib.mkForce metadata.domain; })
                    ];
                  })
                  hostSharedConfig
                  ./hosts/${host}
                ];
              })
          images;

      # My several development shells for usual type of projects. This is much
      # more preferable than installing all of the packages at the system
      # configuration (or even home environment).
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in {
          default = import ./shell.nix { inherit pkgs; };
          docs = import ./docs/shell.nix { inherit pkgs; };
        } // (import ./shells { inherit pkgs; }));

      # Cookiecutter templates for your mama.
      templates = {
        default = self.templates.basic-devshell;
        basic-devshell = {
          path = ./templates/basic-devshell;
          description = "Basic development shell template";
        };
        basic-overlay-flake = {
          path = ./templates/basic-overlay-flake;
          description = "Basic overlay as a flake";
        };
        sample-nixos-template = {
          path = ./templates/sample-nixos-template;
          description = "Simple sample Nix flake with NixOS and home-manager";
        };
      };

      # No amount of formatters will make this codebase nicer but it sure does
      # feel like it does.
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.treefmt);

      # nixops-lite (that is much more powerful than nixops itself)... in
      # here!?! We got it all, son!
      #
      # Also, don't forget to always clean your shell history when overriding
      # sensitive info such as the hostname and such. A helpful tip would be
      # ignoring the shell entry by simply prefixing it with a space which most
      # command-line shells have support for (e.g., Bash, zsh, fish).
      deploy.nodes =
        let
          nixosConfigurations = lib'.mapAttrs'
            (name: value:
              let
                metadata = images.${name};
              in
              lib'.nameValuePair "nixos-${name}" {
                hostname = metadata.deploy.hostname or name;
                autoRollback = metadata.deploy.auto-rollback or true;
                magicRollback = metadata.deploy.magic-rollback or true;
                fastConnection = metadata.deploy.fast-connection or true;
                remoteBuild = metadata.deploy.remote-build or false;
                profiles.system = {
                  sshUser = metadata.deploy.ssh-user or "admin";
                  user = "root";
                  path = inputs.deploy.lib.${metadata.system or defaultSystem}.activate.nixos value;
                };
              })
            self.nixosConfigurations;
          homeConfigurations = lib'.mapAttrs'
            (name: value:
              let
                metadata = users.${name};
                username = metadata.deploy.username or name;
              in
              lib'.nameValuePair "home-manager-${name}" {
                hostname = metadata.deploy.hostname or name;
                autoRollback = metadata.deploy.auto-rollback or true;
                magicRollback = metadata.deploy.magic-rollback or true;
                fastConnection = metadata.deploy.fast-connection or true;
                remoteBuild = metadata.deploy.remote-build or false;
                profiles.home = {
                  sshUser = metadata.deploy.ssh-user or username;
                  user = metadata.deploy.user or username;
                  path = inputs.deploy.lib.${metadata.system or defaultSystem}.activate.home-manager value;
                };
              })
            self.homeConfigurations;
        in
        nixosConfigurations // homeConfigurations;

      # How to make yourself slightly saner than before. So far the main checks
      # are for deploy nodes.
      checks = lib'.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy.lib;

      # I'm cut off from the rest of my setup with no Hydra instance yet but
      # I'm sure it will grow some of them as long as you didn't put it under a
      # rock.
      hydraJobs.build-packages = forAllSystems (system: self.packages.${system});
    };
}
