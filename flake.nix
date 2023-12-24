{
  description = "foo-dogsquared's abomination of a NixOS configuration";

  nixConfig = {
    extra-substituters =
      "https://nix-community.cachix.org https://foo-dogsquared.cachix.org";
    extra-trusted-public-keys =
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E=";
  };

  inputs = {
    # I know NixOS can be stable but we're going cutting edge, baybee! While
    # `nixpkgs-unstable` branch could be faster delivering updates, it is
    # looser when it comes to stability for the entirety of this configuration.
    nixpkgs.follows = "nixos-unstable";

    # Here are the nixpkgs variants used for creating the system configuration
    # in `mkHost`.
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # We're using these libraries for other functions.
    flake-utils.url = "github:numtide/flake-utils";

    # Managing home configurations.
    home-manager.follows = "home-manager-unstable";
    home-manager-stable.url = "github:nix-community/home-manager/release-23.11";
    home-manager-unstable.url = "github:nix-community/home-manager";

    # This is what AUR strives to be.
    nur.url = "github:nix-community/NUR";

    # Generate your NixOS systems to various formats!
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Managing your secrets.
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS in Windows.
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

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

    # Generating an entire flavored themes with Nix?
    nix-colors.url = "github:misterio77/nix-colors";

    # Removing the manual partitioning part with a little boogie.
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Deploying stuff with Nix. This is becoming a monorepo for everything I
    # need and I'm liking it.
    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixpkgs";

    # Add a bunch of pre-compiled indices since mine are always crashing.
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      # A set of images with their metadata that is usually built for usual
      # purposes. The format used here is whatever formats nixos-generators
      # support.
      images = import ./setups/nixos.nix { inherit lib inputs; };

      # A set of users with their metadata to be deployed with home-manager.
      users = import ./setups/home-manager.nix { inherit lib inputs; };

      # A set of image-related utilities for the flake outputs.
      inherit (import ./lib/extras/images.nix { inherit lib inputs; }) mkHost mkHome mkImage listImagesWithSystems;

      # The order here is important(?).
      overlays = lib.attrValues self.overlays;

      defaultSystem = "x86_64-linux";

      # Just add systems here and it should add systems to the outputs.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      extraArgs = {
        inherit (inputs) nix-colors;

        # This is a variable that is used to check whether the module is
        # exported or not. Useful for configuring parts of the configuration
        # that is otherwise that cannot be exported for others' use.
        _isfoodogsquaredcustom = true;
      };

      # We're considering this as the variant since we'll export the custom
      # library as `lib` in the output attribute.
      lib = nixpkgs.lib.extend (import ./lib/extras/extend-lib.nix);

      # The shared configuration for the entire list of hosts for this cluster.
      # Take note to only set as minimal configuration as possible since we're
      # also using this with the stable version of nixpkgs.
      hostSharedConfig = { options, config, lib, pkgs, ... }: {
        # Initialize some of the XDG base directories ourselves since it is
        # used by NIX_PROFILES to properly link some of them.
        environment.sessionVariables = {
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_STATE_HOME = "$HOME/.local/state";
        };

        # Only use imports as minimally as possible with the absolute
        # requirements of a host. On second thought, only on flakes with
        # optional NixOS modules.
        imports =
          # Append with our custom NixOS modules from the modules folder.
          import ./modules/nixos { inherit lib; isInternal = true; }

          # Then, make the most with the modules from the flake inputs. Take
          # note importing some modules such as home-manager are as part of the
          # declarative host config so be sure to check out
          # `hostSpecificModule` function as well as the declarative host setup.
          ++ [
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
          ];

        # Set some extra, yeah?
        _module.args = extraArgs;

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

        # The global configuration for the home-manager module.
        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
        home-manager.sharedModules = [ userSharedConfig ];

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
      };

      # The default config for our home-manager configurations. This is also to
      # be used for sharing modules among home-manager users from NixOS
      # configurations with `nixpkgs.useGlobalPkgs` set to `true` so avoid
      # setting nixpkgs-related options here.
      userSharedConfig = { pkgs, config, lib, ... }: {
        imports =
          # Import our own custom modules from here..
          import ./modules/home-manager { inherit lib; isInternal = true; }

          # ...plus a bunch of third-party modules.
          ++ [
            inputs.nur.hmModules.nur
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-index-database.hmModules.nix-index
          ];

        # Set some extra, yeah?
        _module.args = extraArgs;

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

        manual = lib.mkDefault {
          html.enable = true;
          json.enable = true;
          manpages.enable = true;
        };

        home.stateVersion = lib.mkDefault "23.11";
      };

      # This will be shared among NixOS and home-manager configurations.
      nixSettingsSharedConfig = { config, lib, pkgs, ... }: {
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

        # Set the package for generating the configuration.
        nix.package = lib.mkDefault pkgs.nixUnstable;

        # Set the configurations for the package manager.
        nix.settings = {
          # Set several binary caches.
          substituters = [
            "https://nix-community.cachix.org"
            "https://foo-dogsquared.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E="
          ];

          # Sane config for the package manager.
          # TODO: Remove this after nix-command and flakes has been considered
          # stable.
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
      };

      # A function that generates a Nix module from host metadata.
      hostSpecificModule = host: metadata: let
        modules = metadata.modules or [];
        host = metadata._name or host;
      in
        { lib, ... }: {
          imports = modules ++ [
            inputs.${metadata.home-manager-channel or "home-manager"}.nixosModules.home-manager

            hostSharedConfig
            nixSettingsSharedConfig
            ./hosts/${host}
          ];

          config = lib.mkMerge [
            {
              networking.hostName = lib.mkForce metadata.hostname or host;
              nixpkgs.hostPlatform = metadata._system;
            }

            (lib.mkIf (metadata ? domain)
              { networking.domain = lib.mkForce metadata.domain; })
          ];
        };

      # A function that generates a home-manager module from a given user
      # metadata.
      userSpecificModule = user: metadata: let
        name = metadata.username or metadata._name or user;
        modules = metadata.modules or [];
      in
        { lib, pkgs, config, ... }: {
          imports = modules ++ [
            userSharedConfig
            nixSettingsSharedConfig
            ./users/home-manager/${name}
          ];

          # Don't create the user directories since they are assumed to
          # be already created by a pre-installed system (which should
          # already handle them).
          xdg.userDirs.createDirectories = lib.mkForce false;

          # Setting the homely options.
          home.username = lib.mkForce name;
          home.homeDirectory = lib.mkForce (metadata.home-directory or "/home/${config.home.username}");

          programs.home-manager.enable = lib.mkForce true;
          targets.genericLinux.enable = true;
        };
    in
    {
      # Exposes only my library with the custom functions to make it easier to
      # include in other flakes for whatever reason may be.
      lib = import ./lib { lib = nixpkgs.lib; };

      # A list of NixOS configurations from the `./hosts` folder. It also has
      # some sensible default configurations.
      nixosConfigurations =
        lib.mapAttrs
          (host: metadata:
            mkHost {
              extraModules = [ (hostSpecificModule host metadata) ];
              nixpkgs-channel = metadata.nixpkgs-channel or "nixpkgs";
            })
          (listImagesWithSystems images);

      # We're going to make our custom modules available for our flake. Whether
      # or not this is a good thing is debatable, I just want to test it.
      nixosModules.default = import ./modules/nixos { inherit lib; };

      # I can now install home-manager users in non-NixOS systems.
      # NICE!
      homeConfigurations =
        lib.mapAttrs
          (user: metadata:
            mkHome {
              pkgs = import inputs.${metadata.nixpkgs-channel or "nixpkgs"} {
                system = metadata._system;
              };
              extraModules = [(userSpecificModule user metadata)];
              home-manager-channel = metadata.home-manager-channel or "home-manager";
            })
          (listImagesWithSystems users);

      # Extending home-manager with my custom modules, if anyone cares.
      homeModules.default = import ./modules/home-manager { inherit lib; };

      # In case somebody wants to use my stuff to be included in nixpkgs.
      overlays = import ./overlays // {
        default = final: prev: import ./pkgs { pkgs = prev; };
        firefox-addons = final: prev: {
          inherit (final.nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
          firefox-addons = final.callPackage ./pkgs/firefox-addons { };
        };
      };

      # My custom packages, available in here as well. Though, I mainly support
      # "x86_64-linux". I just want to try out supporting other systems.
      packages = forAllSystems (system:
        inputs.flake-utils.lib.flattenTree (import ./pkgs {
          pkgs = import nixpkgs { inherit system; };
        }));

      # This contains images that are meant to be built and distributed
      # somewhere else including those NixOS configurations that are built as
      # an ISO.
      images =
        forAllSystems (system:
          let
            images' = lib.filterAttrs (host: metadata: (system == metadata._system) && (metadata.format != null)) (listImagesWithSystems images);
          in
          lib.mapAttrs'
            (host: metadata:
              let
                name = metadata._name;
                nixpkgs-channel = metadata.nixpkgs-channel or "nixpkgs";
                format = metadata.format or "iso";
              in
              lib.nameValuePair name (mkImage {
                inherit nixpkgs-channel format;
                extraModules = [ (hostSpecificModule host metadata) ];
              }))
            images');

      # My several development shells for usual type of projects. This is much
      # more preferable than installing all of the packages at the system
      # configuration (or even home environment).
      devShells = forAllSystems (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = overlays ++ [
            inputs.nur.overlay
          ];
        };
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
        local-ruby-nix = {
          path = ./templates/local-ruby-nix;
          description = "Local Ruby app development with ruby-nix";
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
          nixosConfigurations = lib.mapAttrs'
            (name: value:
              let
                metadata = images.${name};
              in
              lib.nameValuePair "nixos-${name}" {
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
          homeConfigurations = lib.mapAttrs'
            (name: value:
              let
                metadata = users.${name};
                username = metadata.deploy.username or name;
              in
              lib.nameValuePair "home-manager-${name}" {
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
      checks = lib.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy.lib;

      # I'm cut off from the rest of my setup with no Hydra instance yet but
      # I'm sure it will grow some of them as long as you didn't put it under a
      # rock.
      hydraJobs.build-packages = forAllSystems (system: self.packages.${system});
    };
}
