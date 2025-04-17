{ lib, config, options, inputs, ... }:

let
  partsConfig = config;
  cfg = config.setups.wrapper-manager;

  mkWrapperManagerPackage = { pkgs, wrapperManagerBranch ? "wrapper-manager-fds", modules ? [ ], specialArgs ? { }, }:
    inputs.${wrapperManagerBranch}.lib.build { inherit pkgs modules specialArgs; };

  wrapperManagerIntegrationModule = { name, config, lib, ... }: {
    options.wrapper-manager = {
      additionalModules = lib.mkOption {
        type = with lib.types; listOf deferredModule;
        default = [ ];
        description = ''
          Additional wrapper-manager modules to be included in the wider-scoped
          environment.
        '';
      };

      branch = lib.mkOption {
        type = with lib.types; nullOr nonEmptyStr;
        default = "wrapper-manager-fds";
        example = "wrapper-manager-fds-stable";
        description = ''
          Name of the flake input containing the wrapper-manager-fds dependency.
        '';
      };

      packages = lib.mkOption {
        type = with lib.types;
          attrsOf (submodule {
            options.additionalModules = lib.mkOption {
              type = with lib.types; listOf deferredModule;
              description = ''
                Additional wrapper-manager modules to be included into the given
                declarative wrapper-manager configuration.
              '';
              default = [ ];
            };
          });
        default = { };
        description = ''
          Include declared wrapper-manager packages into the wider environment.
        '';
      };
    };

    config = lib.mkIf (config.wrapper-manager.packages != { }) {
      modules = [
        ({ lib, ... }: {
          wrapper-manager.sharedModules = cfg.sharedModules
            ++ config.wrapper-manager.additionalModules;

          wrapper-manager.packages = lib.mapAttrs (name: wmPackage: {
            imports = partsConfig.setups.wrapper-manager.configs.${name}.modules
              ++ wmPackage.additionalModules;
          }) config.wrapper-manager.packages;
        })
      ];
    };
  };

  wrapperManagerConfigModule = { name, config, lib, ... }: {
    config = {
      nixpkgs.config = cfg.sharedNixpkgsConfig;
      specialArgs = cfg.sharedSpecialArgs;

      modules = [
        "${partsConfig.setups.configDir}/wrapper-manager/${config.configName}"
      ];
    };
  };
in {
  options.setups.wrapper-manager = {
    sharedNixpkgsConfig = options.setups.sharedNixpkgsConfig // {
      description = ''
        The nixpkgs configuration to be passed to all of the declarative
        wrapper-manager configurations.
      '';
    };

    configs = lib.mkOption {
      type = with lib.types;
        attrsOf (submodule [
          (import ./shared/config-options.nix { inherit (config) systems; })
          ./shared/nixpkgs-options.nix
          ./shared/special-args-options.nix
          wrapperManagerConfigModule
        ]);
      default = { };
      description = ''
        Declarative wrapper-manager packages to be exported into the flake.
      '';
      example = lib.literalExpression ''
        {
          music-setup = {
            modules = [
              { config.build.isBinary = false; }
            ];
          };
        }
      '';
    };

    sharedSpecialArgs = options.setups.sharedSpecialArgs // {
      description = ''
        Shared set of module arguments as part of `_module.specialArgs` of the
        configuration.
      '';
    };

    sharedModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      description = ''
        List of shared wrapper-manager modules in all of the declarative
        wrapper-manager configurations.
      '';
    };

    standaloneModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      description = ''
        List of wrapper-manager modules only available at standalone mode.
      '';
    };
  };

  # Integrations with the composable environments such as NixOS and home-manager.
  options.setups.nixos.configs = lib.mkOption {
    type = with lib.types;
      attrsOf (submodule [
        wrapperManagerIntegrationModule
        ({ config, lib, ... }: {
          config = lib.mkIf (config.wrapper-manager.packages != { }) {
            modules =
              [
                inputs.${config.wrapper-manager.branch}.nixosModules.default

                {
                  # Welp, it's not complete since each package will not its
                  # package-specific specialArgs.
                  wrapper-manager.extraSpecialArgs = cfg.sharedSpecialArgs;
                }
              ];
          };
        })
      ]);
  };

  options.setups.home-manager.configs = lib.mkOption {
    type = with lib.types;
      attrsOf (submodule [
        wrapperManagerIntegrationModule
        ({ config, lib, ... }: {
          config = lib.mkMerge [
            (lib.mkIf (config.wrapper-manager.branch != null) {
              modules = [
                inputs.${config.wrapper-manager.branch}.homeModules.default

                # Welp, it's not complete since each package will not its
                # package-specific specialArgs.
                { wrapper-manager.extraSpecialArgs = cfg.sharedSpecialArgs; }
              ];
            })
          ];
        })
      ]);
  };

  config = lib.mkMerge [
    {
      setups.wrapper-manager.sharedNixpkgsConfig =
        config.setups.sharedNixpkgsConfig;

      setups.wrapper-manager.sharedSpecialArgs =
        config.setups.sharedSpecialArgs;
    }

    (lib.mkIf (cfg.configs != { }) {
      perSystem = { system, config, lib, ... }:
        let
          validWrapperManagerConfigs =
            lib.filterAttrs (_: metadata: lib.elem system metadata.systems)
            cfg.configs;
        in {
          wrapperManagerPackages = lib.mapAttrs (name: metadata:
            let
              pkgs = import inputs.${metadata.nixpkgs.branch} {
                inherit (metadata.nixpkgs) config;
                inherit system;
              };
            in mkWrapperManagerPackage {
              inherit pkgs;
              inherit (metadata) specialArgs;
              wrapperManagerBranch = metadata.wrapper-manager.branch;
              modules = cfg.sharedModules ++ cfg.standaloneModules
                ++ metadata.modules;
            }) validWrapperManagerConfigs;
        };
    })
  ];
}
