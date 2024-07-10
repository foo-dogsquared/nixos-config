# This is the declarative user management converted into a flake-parts module.
{ config, lib, inputs, ... }:

let
  cfg = config.setups.home-manager;
  homeManagerModules = ../../home-manager;
  partsConfig = config;

  # A thin wrapper around the home-manager configuration function.
  mkHome =
    { system
    , nixpkgsBranch ? "nixpkgs"
    , homeManagerBranch ? "home-manager"
    , extraModules ? [ ]
    , specialArgs ? { }
    }:
    let
      pkgs = inputs.${nixpkgsBranch}.legacyPackages.${system};
    in
    inputs.${homeManagerBranch}.lib.homeManagerConfiguration {
      extraSpecialArgs = specialArgs // {
        foodogsquaredModulesPath = builtins.toString homeManagerModules;
      };

      inherit pkgs;
      lib = pkgs.lib;
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

        (lib.mkIf (config.nixvim.instance != null)
          ({ lib, ... }: {
            imports = [
              inputs.${config.nixvim.branch}.homeManagerModules.nixvim
            ];

            config.programs.nixvim = { ... }: {
              enable = lib.mkDefault true;
              imports =
                partsConfig.setups.nixvim.configs.${config.nixvim.instance}.modules
                ++ partsConfig.setups.nixvim.sharedModules
                ++ config.nixvim.additionalModules;
            };
          }))
      ];
    };
  };
in
{
  options.setups.home-manager = {
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
      type = with lib.types; attrsOf (submoduleWith {
        specialArgs = { inherit (config) systems; };
        modules = [
          (import ./shared/nix-conf.nix { inherit inputs; })
          ./shared/nixpkgs-options.nix
          ./shared/nixvim-instance-options.nix
          ./shared/config-options.nix
          configType
        ];
      });
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

  config = lib.mkIf (cfg.configs != { }) {
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
                    lib.nameValuePair system (mkHome {
                      inherit (metadata) nixpkgsBranch homeManagerBranch;
                      inherit system;
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
