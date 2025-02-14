{ lib, config, options, inputs, ... }:

let
  partsConfig = config;
  cfg = config.setups.wrapper-manager;

  mkWrapperManagerPackage = { pkgs, src, modules ? [ ], specialArgs ? { }, }:
    let wrapperManagerEntrypoint = import src { };
    in wrapperManagerEntrypoint.lib.build { inherit pkgs modules specialArgs; };

  wrapperManagerIntegrationModule = { name, config, lib, ... }: {
    options.wrapper-manager = {
      src = lib.mkOption {
        type = lib.types.path;
        default = ../../../subprojects/wrapper-manager-fds;
        description = ''
          The path of the wrapper-manager-fds to be used to properly initialize
          to the environment.
        '';
      };

      additionalModules = lib.mkOption {
        type = with lib.types; listOf deferredModule;
        default = [ ];
        description = ''
          Additional wrapper-manager modules to be included in the wider-scoped
          environment.
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
    options.wrapper-manager.src = lib.mkOption {
      type = lib.types.path;
      default = ../../../subprojects/wrapper-manager-fds;
      description = ''
        The path containing wrapper-manager-fds source code to be used to
        properly initialize and create the wrapper-manager environment.
      '';
    };

    config = {
      nixpkgs.config = cfg.sharedNixpkgsConfig;

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
              [ (import config.wrapper-manager.src { }).nixosModules.default ];
          };
        })
      ]);
  };

  options.setups.home-manager.configs = lib.mkOption {
    type = with lib.types;
      attrsOf (submodule [
        wrapperManagerIntegrationModule
        ({ config, lib, ... }: {
          config = lib.mkIf (config.wrapper-manager.packages != { }) {
            modules =
              [ (import config.wrapper-manager.src { }).homeModules.default ];
          };
        })
      ]);
  };

  config = lib.mkMerge [
    {
      setups.wrapper-manager.sharedNixpkgsConfig =
        config.setups.sharedNixpkgsConfig;
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
              inherit (metadata.wrapper-manager) src;
              modules = cfg.sharedModules ++ cfg.standaloneModules
                ++ metadata.modules;
            }) validWrapperManagerConfigs;
        };
    });
  ];
}
