{ inputs
, lib
, config

, defaultOverlays

, ... }:

let
  cfg = config.setups.nixvim;
  partsConfig = config;
  nixvimModules = ../../nixvim;

  mkNixvimConfig = { system, nixpkgsBranch, modules ? [] }:
    let
      pkgs = import inputs.${nixpkgsBranch} {
        inherit system;
        config.allowUnfree = true;
      };
    in
    inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
      inherit pkgs;
      module = {
        imports = modules;
      };
      extraSpecialArgs = {
        foodogsquaredModulesPath = builtins.toString nixvimModules;
      };
    };

  modulesOption = lib.mkOption {
    type = with lib.types; listOf raw;
    default = [];
  };
  modulesOption' = configEnv: modulesOption // {
    description = ''
      A list of NixVim modules to be applied across all NixVim configurations
      when imported as part of ${configEnv}.
    '';
  };

  configType = { name, lib, config, ... }: {
    options = {
      systems = lib.mkOption {
        type = with lib.types; listOf str;
        default = partsConfig.systems;
        defaultText = "config.systems";
        example = [ "x86_64-linux" "aarch64-linux" ];
        description = ''
          A list of systems the NixVim configuration will be built against.
        '';
      };

      nixpkgsBranches = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          A list of nixpkgs branches for the NixVim configuration to be built
          against.
        '';
        example = [
          "nixos-unstable"
          "nixos-stable"
        ];
      };

      modules = lib.mkOption {
        type = with lib.types; listOf raw;
        default = [];
        description = ''
          Additional NixVim modules to use.
        '';
      };
    };

    config = {
      modules = [
        ../../../configs/nixvim/${name}
      ];
    };
  };
in
{
  options.setups.nixvim = {
    configs = lib.mkOption {
      type = with lib.types; attrsOf (submodule configType);
      default = {};
      description = ''
        A set of NixVim configurations to be integrated into the declarative
        setups configuration. Each of them will be available as part of
        `nixvimConfigurations`.
      '';
    };

    sharedModules = modulesOption // {
      description = ''
        A list of NixVim modules to be shared across all of the NixVim
        configurations.
      '';
    };
    standaloneConfigModules = modulesOption' "standalone configuration";
  };

  config = lib.mkIf (cfg.configs != {}) {
    setups.nixvim.sharedModules = [ nixvimModules ];

    perSystem = { system, config, lib, ... }:
      (
        let
          validConfigs = lib.filterAttrs
            (_: metadata: lib.elem system metadata.systems) cfg.configs;

          nixvimConfigurations =
            let
              generateNixvimConfigs = name: metadata:
                let
                  mkNixvim = nixpkgsBranch:
                    lib.nameValuePair
                      "${name}-${nixpkgsBranch}"
                      (mkNixvimConfig {
                        inherit system nixpkgsBranch;
                        modules =
                          cfg.sharedModules
                          ++ cfg.standaloneConfigModules
                          ++ metadata.modules;
                      });

                  nixvimConfigs = builtins.map mkNixvim metadata.nixpkgsBranches;
                in
                lib.listToAttrs nixvimConfigs;
            in
            lib.concatMapAttrs generateNixvimConfigs validConfigs;
        in
        {
          # We'll reuse these.
          inherit nixvimConfigurations;

          checks =
            lib.mapAttrs'
              (name: nvim:
                lib.nameValuePair
                  "nixvim-check-${name}"
                  (inputs.nixvim.lib.${system}.check.mkTestDerivationFromNvim {
                  inherit nvim;
                  name = "${name} configuration";
                  }))
              nixvimConfigurations;
        }
      );
  };
}
