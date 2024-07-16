# This is the declarative host management converted into a flake-parts module.
# It also enforces a structure for declarative NixOS setups such as a mandatory
# inclusion of the home-manager NixOS module, a deploy-rs node, a hostname and
# an optional domain, and deploy-rs-related options so it isn't really made to
# be generic or anything like that.
{ config, options, lib, inputs, ... }:

let
  cfg = config.setups.nixos;
  nixosModules = ../../nixos;

  # This is used on a lot of the Nix modules below.
  partsConfig = config;

  # A thin wrapper around the NixOS configuration function.
  mkHost = {
    system,
    extraModules ? [ ],
    nixpkgsBranch ? "nixpkgs",
    nixpkgsConfig ? { },
    specialArgs ? { },
  }:
    let
      nixpkgs = inputs.${nixpkgsBranch};

      # Just to be sure, we'll use everything with the given nixpkgs' stdlib.
      pkgs = import nixpkgs { inherit system; config = nixpkgsConfig; };
      lib = pkgs.lib;

      # Evaluating the system ourselves (which is trivial) instead of relying
      # on nixpkgs.lib.nixosSystem flake output.
      nixosSystem = args: import "${nixpkgs}/nixos/lib/eval-config.nix" args;
    in
    (lib.makeOverridable nixosSystem) {
      inherit pkgs;
      specialArgs = specialArgs // {
        foodogsquaredUtils = import ../../../lib/utils/nixos.nix { inherit lib; };
        foodogsquaredModulesPath = builtins.toString nixosModules;
      };
      modules = extraModules ++ [{
        nixpkgs.hostPlatform = lib.mkForce system;
      }];

      # Since we're setting it through nixpkgs.hostPlatform, we'll have to pass
      # this as null.
      system = null;
    };

  # The nixos-generators modules set as well as our custom-made ones.
  nixosGeneratorsModulesSet =
    let
      importNixosGeneratorModule = (_: modulePath: {
        imports = [
          modulePath
          "${inputs.nixos-generators}/format-module.nix"
        ];
      });

      customFormats = lib.mapAttrs importNixosGeneratorModule {
        install-iso-graphical = ../../nixos-generators/install-iso-graphical.nix;
      };
    in
    inputs.nixos-generators.nixosModules // customFormats;

  # A very very thin wrapper around `mkHost` to build with the given format.
  mkImage =
    { system
    , nixpkgsBranch ? "nixpkgs"
    , extraModules ? [ ]
    , format ? "iso"
    }:
    let
      extraModules' =
        extraModules ++ [ nixosGeneratorsModulesSet.${format} ];
      image = mkHost {
        inherit nixpkgsBranch system;
        extraModules = extraModules';
      };
    in
    image.config.system.build.${image.config.formatAttr};

  deployNodeType = { config, lib, ... }: {
    freeformType = with lib.types; attrsOf anything;
    imports = [ ./shared/deploy-node-type.nix ];

    options = {
      profiles = lib.mkOption {
        type = with lib.types; functionTo (attrsOf anything);
        default = os: {
          system = {
            sshUser = "root";
            user = "admin";
            path = inputs.deploy.lib.${os.system}.activate.nixos os.config;
          };
        };
        defaultText = lib.literalExpression ''
          os: {
            system = {
              sshUser = "root";
              user = "admin";
              path = <deploy-rs>.lib.''${os.system}.activate.nixos os.config;
            };
          }
        '';
        description = ''
          A set of profiles for the resulting deploy node.

          Since each config can result in more than one NixOS system, it has to
          be a function where the passed argument is an attribute set with the
          following values:

          * `name` is the attribute name from `configs`.
          * `config` is the NixOS configuration itself.
          * `system` is a string indicating the platform of the NixOS system.

          If unset, it will create a deploy-rs node profile called `system`
          similar to those from nixops.
        '';
      };
    };
  };

  homeManagerUserType = { name, config, lib, ... }: {
    options = {
      userConfig = lib.mkOption {
        type = with lib.types; attrsOf anything;
        description = ''
          The configuration applied for individual users set in the
          wider-scoped environment.
        '';
      };
    };

    config =
      let
        hmUserConfig = partsConfig.setups.home-manager.configs.${name};
      in
      {
        userConfig = {
          isNormalUser = lib.mkDefault true;
          createHome = lib.mkDefault true;
          home = lib.mkForce hmUserConfig.homeDirectory;
        };

        additionalModules = [
          ({ lib, ... }: {
            home.homeDirectory = lib.mkForce hmUserConfig.homeDirectory;
            home.username = lib.mkForce name;
          })
        ];
      };
  };

  configType = { options, config, name, lib, ... }: let
    setupConfig = config;
  in {
    options = {
      formats = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = [ "iso" ];
        description = ''
          The image formats to be generated from nixos-generators. When given
          as `null`, it is listed as part of `nixosConfigurations` and excluded
          from `images` flake output which is often the case for desktop NixOS
          systems.
        '';
      };

      hostname = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = name;
        example = "MyWhatNow";
        description = "The hostname of the NixOS configuration.";
      };

      domain = lib.mkOption {
        type = with lib.types; nullOr nonEmptyStr;
        default = null;
        example = "work.example.com";
        description = "The domain of the NixOS system.";
      };

      home-manager = {
        # Extending it with more NixOS-specific user options.
        users = lib.mkOption {
          type = with lib.types; attrsOf (submodule homeManagerUserType);
        };

        nixpkgsInstance = lib.mkOption {
          type = lib.types.enum [ "global" "separate" "none" ];
          default = "global";
          description = ''
            Indicates how to manage the nixpkgs instance (or instances)
            of the holistic system. This will also dictate how to import
            overlays from
            {option}`setups.home-manager.configs.<user>.overlays`.

            * `global` enforces to use one nixpkgs instance for all
            home-manager users and imports all of the overlays into the
            nixpkgs instance of the NixOS system.

            * `separate` enforces the NixOS system to use individual
            nixpkgs instance for all home-manager users and imports the
            overlays to the nixpkgs instance of the home-manager user.

            * `none` leave the configuration alone and do not import
            overlays at all where you have to set them yourself. This is
            the best option if you want more control over each individual
            NixOS and home-manager configuration.

            The default value is set to `global` which is the encouraged
            practice with this module.
          '';
        };
      };

      deploy = lib.mkOption {
        type = with lib.types; nullOr (submodule deployNodeType);
        default = null;
        description = ''
          deploy-rs node settings for the resulting NixOS configuration. When
          this attribute is given with a non-null value, it will be included in
          `nixosConfigurations` even if
          {option}`setups.nixos.configs.<config>.formats` is set.
        '';
        example = {
          hostname = "work1.example.com";
          fastConnection = true;
          autoRollback = true;
          magicRollback = true;
          remoteBuild = true;
        };
      };

      diskoConfigs = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = [ "external-hdd" ];
        description = ''
          A list of declarative Disko configurations to be included alongside
          the NixOS configuration.
        '';
      };

      shouldBePartOfNixOSConfigurations = lib.mkOption {
        type = lib.types.bool;
        default = lib.isAttrs config.deploy || config.formats == null;
        example = true;
        description = ''
          Indicates whether the declarative NixOS setup should be included as
          part of the `nixosConfigurations` flake output.
        '';
      };
    };

    config.nixpkgs.config = cfg.sharedNixpkgsConfig;

    config.modules = [
      # Bring in the required modules.
      inputs.${config.home-manager.branch}.nixosModules.home-manager
      ../../../configs/nixos/${config.configName}

      # Mapping the declarative home-manager users (if it has one) into NixOS
      # users.
      (lib.mkIf (config.home-manager.users != { })
        (
          let
            inherit (config.home-manager) nixpkgsInstance;

            hasHomeManagerUsers = config.home-manager.users != { };
            isNixpkgs = state: hasHomeManagerUsers && nixpkgsInstance == state;
          in
          { config, lib, pkgs, ... }: {
            config = lib.mkMerge [
              (lib.mkIf hasHomeManagerUsers {
                users.users =
                  lib.mapAttrs
                    (name: hmUser: hmUser.userConfig)
                    setupConfig.home-manager.users;

                home-manager.users =
                  lib.mapAttrs
                    (name: hmUser: {
                      imports =
                        partsConfig.setups.home-manager.configs.${name}.modules
                        ++ hmUser.additionalModules;
                    })
                    setupConfig.home-manager.users;
              })

              (lib.mkIf (isNixpkgs "global") {
                home-manager.useGlobalPkgs = lib.mkForce true;

                # Disable all options that are going to be blocked once
                # `home-manager.useGlobalPkgs` is used.
                home-manager.users =
                  lib.mapAttrs
                    (name: _: {
                      nixpkgs.overlays = lib.mkForce null;
                      nixpkgs.config = lib.mkForce null;
                    })
                    setupConfig.home-manager.users;

                # Then apply all of the user overlays into the nixpkgs instance
                # of the NixOS system.
                nixpkgs.overlays =
                  let
                    hmUsersOverlays =
                      lib.mapAttrsToList
                        (name: _:
                          partsConfig.setups.home-manager.configs.${name}.nixpkgs.overlays)
                        setupConfig.home-manager.users;

                    overlays = lib.lists.flatten hmUsersOverlays;
                  in
                  # Most of the overlays are going to be imported from a
                    # variable anyways. This should massively reduce the step
                    # needed for nixpkgs to do its thing.
                    #
                    # Though, it becomes unpredictable due to the way how the
                    # overlay list is constructed. However, this is much more
                    # preferable than letting a massive list with duplicated
                    # overlays from different home-manager users to be applied.
                    #
                    # Anyways, all I'm saying is that this is a massive hack
                    # because it isn't correct.
                  lib.lists.unique overlays;
              })

              (lib.mkIf (isNixpkgs "separate") {
                home-manager.useGlobalPkgs = lib.mkForce false;
                home-manager.users =
                  lib.mapAttrs
                    (name: _: {
                      nixpkgs.overlays =
                        partsConfig.setups.home-manager.configs.${name}.nixpkgs.overlays;
                    })
                    setupConfig.home-manager.users;
              })
            ];
          }
        ))

      # Next, we include the chosen NixVim configuration into NixOS.
      (lib.mkIf (config.nixvim.instance != null)
        (
          { lib, ... }: {
            imports = [ inputs.${config.nixvim.branch}.nixosModules.nixvim ];

            programs.nixvim = { ... }: {
              enable = lib.mkDefault true;
              imports =
                partsConfig.setups.nixvim.configs.${config.nixvim.instance}.modules
                ++ partsConfig.setups.nixvim.sharedModules
                ++ setupConfig.nixvim.additionalModules;
            };
          }
        ))

      # Then we include the Disko configuration (if there's any).
      (lib.mkIf (config.diskoConfigs != [ ]) (
        let
          diskoConfigs =
            builtins.map (name: import ../../../configs/disko/${name}) config.diskoConfigs;
        in
        {
          imports =
            [ inputs.disko.nixosModules.disko ]
            ++ (lib.lists.flatten diskoConfigs);
        })
      )

      # Setting up the typical configuration.
      (
        { config, lib, ... }: {
          config = lib.mkMerge [
            {
              nixpkgs.overlays = setupConfig.nixpkgs.overlays;
              networking.hostName = lib.mkDefault setupConfig.hostname;
            }

            (lib.mkIf (setupConfig.domain != null) {
              networking.domain = lib.mkDefault setupConfig.domain;
            })
          ];
        }
      )
    ];
  };
in
{
  options.setups.nixos = {
    sharedNixpkgsConfig = options.setups.sharedNixpkgsConfig // {
      description = ''
        Shared configuration between all of the nixpkgs instance of the
        declarative NixOS systems.

        ::: {.note}
        This is implemented since the way how NixOS systems built here are made
        with initializing a nixpkgs instance ourselves and NixOS doesn't allow
        configuring the nixpkgs instances that are already defined outside of
        its module environment.
        :::
      '';
    };

    sharedModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      description = ''
        A list of modules to be shared by all of the declarative NixOS setups.
      '';
    };

    configs = lib.mkOption {
      type = with lib.types; attrsOf (submoduleWith {
        specialArgs = { inherit (config) systems; };
        modules = [
          (import ./shared/nix-conf.nix { inherit inputs; })
          ./shared/config-options.nix
          ./shared/nixvim-instance-options.nix
          ./shared/home-manager-users.nix
          ./shared/nixpkgs-options.nix
          configType
        ];
      });
      default = { };
      description = ''
        An attribute set of metadata for the declarative NixOS setups. This
        will then be used for related flake outputs such as
        `nixosConfigurations` and `images`.

        ::: {.note}
        For `nixosConfigurations` output, each of them is a pure NixOS
        configuration where `nixpkgs.hostPlatform` is set and each of the
        config is renamed into `$CONFIGNAME-$SYSTEM` if the host is configured
        to have more than one system.
        :::
      '';
      example = lib.literalExpression ''
        {
          desktop = {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            formats = null;
            modules = [
              inputs.nur.nixosModules.nur
            ];
            nixpkgs = {
              branch = "nixos-unstable";
              overlays = [
                # Neovim nightly!
                inputs.neovim-nightly-overlay.overlays.default

                # Emacs unstable version!
                inputs.emacs-overlay.overlays.default

                # Helix master!
                inputs.helix-editor.overlays.default

                # Access to NUR.
                inputs.nur.overlay
              ];
            };
          };

          server = {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            domain = "work.example.com";
            formats = [ "do" "linode" ];
            nixpkgs.branch = "nixos-unstable-small";
            deploy = {
              autoRollback = true;
              magicRollback = true;
            };
          };

          vm = {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            formats = [ "vm" ];
          };
        }
      '';
    };
  };

  config = lib.mkIf (cfg.configs != { }) {
    setups.nixos.sharedNixpkgsConfig = config.setups.sharedNixpkgsConfig;

    setups.nixos.sharedModules = [
      # Import our own public NixOS modules.
      nixosModules

      # Import our private modules.
      ../../nixos/_private

      # Set the home-manager-related settings.
      ({ lib, ... }: {
        home-manager.sharedModules = partsConfig.setups.home-manager.sharedModules;

        # These are just the recommended options for home-manager that may be
        # the default value in the future but this is how most of the NixOS
        # setups are already done so...
        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
      })
    ];

    flake =
      let
        # A quick data structure we can pass through multiple build pipelines.
        pureNixosConfigs =
          let
            validConfigs =
              lib.filterAttrs (_: v: v.shouldBePartOfNixOSConfigurations) cfg.configs;

            generatePureConfigs = hostname: metadata:
              lib.listToAttrs
                (builtins.map
                  (system:
                    lib.nameValuePair system (mkHost {
                      nixpkgsBranch = metadata.nixpkgsBranch;
                      nixpkgsConfig = metadata.nixpkgs.config;
                      extraModules = cfg.sharedModules ++ metadata.modules;
                      inherit system;
                    })
                  )
                  metadata.systems);
          in
          lib.mapAttrs generatePureConfigs validConfigs;
      in
      {
        nixosConfigurations =
          let
            renameSystem = name: system: config:
              lib.nameValuePair "${name}-${system}" config;
          in
          lib.concatMapAttrs
            (name: configs:
              lib.mapAttrs' (renameSystem name) configs)
            pureNixosConfigs;

        deploy.nodes =
          let
            validConfigs =
              lib.filterAttrs
                (name: _: cfg.configs.${name}.deploy != null)
                pureNixosConfigs;

            generateDeployNode = name: system: config:
              lib.nameValuePair "nixos-${name}-${system}"
                (
                  let
                    deployConfig = cfg.configs.${name}.deploy;
                  in
                  deployConfig
                  // {
                    profiles =
                      cfg.configs.${name}.deploy.profiles {
                        inherit name config system;
                      };
                  }
                );
          in
          lib.concatMapAttrs
            (name: configs:
              lib.mapAttrs' (generateDeployNode name) configs)
            validConfigs;
      };

    perSystem = { system, lib, ... }: {
      images =
        let
          validImages = lib.filterAttrs
            (host: metadata:
              metadata.formats != null && (lib.elem system metadata.systems))
            cfg.configs;

          generateImages = name: metadata:
            let
              buildImage = format:
                lib.nameValuePair
                  "${name}-${format}"
                  (mkImage {
                    inherit (metadata) nixpkgsBranch;
                    inherit system format;
                    extraModules = cfg.sharedModules ++ metadata.modules;
                  });

              images =
                builtins.map buildImage metadata.formats;
            in
            lib.listToAttrs images;
        in
        lib.concatMapAttrs generateImages validImages;
    };
  };
}
