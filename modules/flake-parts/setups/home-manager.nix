# This is the declarative user management converted into a flake-parts module.
# Take note, it reinforces mandatory import of home-manager to its composed
# environments such as NixOS.
{ config, options, lib, inputs, ... }:

let
  cfg = config.setups.home-manager;
  partsConfig = config;
  homeManagerModules = ../../home-manager;

  # A thin wrapper around the home-manager configuration function.
  mkHome =
    { pkgs
    , lib ? pkgs.lib
    , system
    , homeManagerBranch ? "home-manager"
    , extraModules ? [ ]
    , specialArgs ? { }
    }:
    inputs.${homeManagerBranch}.lib.homeManagerConfiguration {
      extraSpecialArgs = specialArgs // {
        foodogsquaredModulesPath = builtins.toString homeManagerModules;
      };

      inherit pkgs lib;
      modules = extraModules;
    };

  deploySettingsType = { config, lib, username, ... }: {
    freeformType = with lib.types; attrsOf anything;
    imports = [ ./shared/deploy-node-type.nix ];

    options = {
      profiles = lib.mkOption {
        type = with lib.types; functionTo (attrsOf anything);
        default = homeenv: {
          home = {
            sshUser = homeenv.name;
            user = homeenv.name;
            path = inputs.deploy.lib.${homeenv.system}.activate.home-manager homeenv.config;
          };
        };
        defaultText = lib.literalExpression ''
          homeenv: {
            home = {
              sshUser = "''${homeenv.name}";
              user = "''${homeenv.name}";
              path = <deploy-rs>.lib.''${homeenv.system}.activate.home-manager homeenv.config;
            };
          }
        '';
        description = ''
          A set of profiles for the resulting deploy node.

          Since each config can result in more than one home-manager
          environment, it has to be a function where the passed argument is an
          attribute set with the following values:

          * `name` is the attribute name from `configs`.
          * `config` is the home-manager configuration itself.
          * `system` is a string indicating the platform of the NixOS system.

          If unset, it will create a deploy-rs node profile called `home`
          similar to those from nixops.
        '';
      };
    };
  };

  configType = { config, name, lib, ... }: {
    options = {
      homeManagerBranch = lib.mkOption {
        type = lib.types.str;
        default = "home-manager";
        example = "home-manager-stable";
        description = ''
          The home-manager branch to be used for the NixOS module. By default,
          it will use the `home-manager` flake input.
        '';
      };

      homeDirectory = lib.mkOption {
        type = lib.types.path;
        default = "/home/${name}";
        example = "/var/home/public-user";
        description = ''
          The home directory of the home-manager user.
        '';
      };

      deploy = lib.mkOption {
        type = with lib.types; nullOr (submoduleWith {
          specialArgs = {
            username = name;
          };
          modules = [ deploySettingsType ];
        });
        default = null;
        description = ''
          deploy-rs settings to be passed onto the home-manager configuration
          node.
        '';
      };
    };

    config = {
      modules = [
        ../../../configs/home-manager/${config.configName}

        (
          let
            setupConfig = config;
          in
          { config, lib, ... }: {
            nixpkgs.overlays = setupConfig.nixpkgs.overlays;
            home.username = lib.mkForce name;
            home.homeDirectory = lib.mkForce setupConfig.homeDirectory;
          }
        )
      ];

      nixpkgs.config = cfg.sharedNixpkgsConfig;
    };
  };
in
{
  options.setups.home-manager = {
    sharedNixpkgsConfig = options.setups.sharedNixpkgsConfig // {
      description = ''
        nixpkgs configuration to be shared among home-manager configurations
        defined here.
      '';
    };

    sharedModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      description = ''
        A list of modules to be shared by all of the declarative home-manager
        setups.

        ::: {.note}
        Note this will be shared into NixOS as well through the home-manager
        NixOS module.
        :::
      '';
    };

    standaloneConfigModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      internal = true;
      description = ''
        A list of modules to be added alongside the shared home-manager modules
        in the standalone home-manager configurations.

        This is useful for modules that are only suitable for standalone
        home-manager configurations compared to home-manager configurations
        used as a NixOS module.
      '';
    };

    configs = lib.mkOption {
      type = with lib.types; attrsOf (submodule [
        (import ./shared/nix-conf.nix { inherit inputs; })
        (import ./shared/config-options.nix { inherit (config) systems; })
        ./shared/nixpkgs-options.nix
        configType
      ]);
      default = { };
      description = ''
        An attribute set of metadata for the declarative home-manager setups.
      '';
      example = lib.literalExpression ''
        {
          foo-dogsquared = {
            systems = [ "aarch64-linux" "x86_64-linux" ];
            modules = [
              inputs.nur.hmModules.nur
              inputs.nixvim.homeManagerModules.nixvim
            ];
            nixpkgs.overlays = [
              inputs.neovim-nightly-overlay.overlays.default
              inputs.emacs-overlay.overlays.default
              inputs.helix-editor.overlays.default
              inputs.nur.overlay
            ];
          };

          plover.systems = [ "x86_64-linux" ];
        }
      '';
    };
  };

  # Setting up all of the integrations for the wider-scoped environments.
  options.setups.nixos.configs = lib.mkOption {
    type = with lib.types; attrsOf (submodule [
      ./shared/home-manager-users.nix

      ({ config, lib, name, ... }: let
        inherit (config.home-manager) nixpkgsInstance;
        setupConfig = config;

        hasHomeManagerUsers = config.home-manager.users != { };
        isNixpkgs = state: hasHomeManagerUsers && nixpkgsInstance == state;
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
      in {
        options.home-manager = {
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

        # Mapping the declarative home-manager users (if it has one) into NixOS
        # users.
        config = {
          modules = [
            # For declarative NixOS systems, importing home-manager module is
            # mandatory.
            inputs.${config.home-manager.branch}.nixosModules.home-manager

            # Set the home-manager-related settings.
            ({ lib, ... }: {
              home-manager.sharedModules = partsConfig.setups.home-manager.sharedModules;

              # These are just the recommended options for home-manager that may be
              # the default value in the future but this is how most of the NixOS
              # setups are already done so...
              home-manager.useUserPackages = lib.mkDefault true;
              home-manager.useGlobalPkgs = lib.mkDefault true;
            })

            (lib.mkIf hasHomeManagerUsers ({ lib, pkgs, ... }: {
              config = lib.mkMerge [
                {
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
                }

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
            }))
          ];
        };
      })
    ]);
  };

  config = lib.mkIf (cfg.configs != { }) {
    setups.home-manager.sharedNixpkgsConfig = config.setups.sharedNixpkgsConfig;

    # Import our own home-manager modules.
    setups.home-manager.sharedModules = [
      homeManagerModules

      # Import our private modules...
      ../../home-manager/_private
    ];

    flake =
      let
        # A quick data structure we can pass through multiple build pipelines.
        pureHomeManagerConfigs =
          let
            generatePureConfigs = username: metadata:
              lib.listToAttrs
                (builtins.map
                  (system:
                    let
                      nixpkgs = inputs.${metadata.nixpkgs.branch};

                      # We won't apply the overlays here since it is set
                      # modularly.
                      pkgs = import nixpkgs {
                        inherit system;
                        inherit (metadata.nixpkgs) config;
                      };
                    in
                    lib.nameValuePair system (mkHome {
                      inherit pkgs system;
                      inherit (metadata) homeManagerBranch;
                      extraModules =
                        cfg.sharedModules
                        ++ cfg.standaloneConfigModules
                        ++ metadata.modules;
                    })
                  )
                  metadata.systems);
          in
          lib.mapAttrs generatePureConfigs cfg.configs;
      in
      {
        homeConfigurations =
          let
            renameSystems = name: system: config:
              lib.nameValuePair "${name}-${system}" config;
          in
          lib.concatMapAttrs
            (name: configs:
              lib.mapAttrs' (renameSystems name) configs)
            pureHomeManagerConfigs;

        deploy.nodes =
          let
            validConfigs =
              lib.filterAttrs
                (name: _: cfg.configs.${name}.deploy != null)
                pureHomeManagerConfigs;

            generateDeployNode = name: system: config:
              lib.nameValuePair "home-manager-${name}-${system}" (
                let
                  deployConfig = cfg.configs.${name}.deploy;
                  deployConfig' = lib.attrsets.removeAttrs deployConfig [ "profiles" ];
                in
                deployConfig'
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
  };
}
