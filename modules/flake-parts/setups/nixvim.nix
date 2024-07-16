{ inputs
, lib
, config
, options

, ...
}:

let
  cfg = config.setups.nixvim;
  nixvimModules = ../../nixvim;

  mkNixvimConfig = {
    system,
    pkgs,
    nixvimBranch ? "nixvim",
    modules ? [ ],
    specialArgs ? { },
  }:
    inputs.${nixvimBranch}.legacyPackages.${system}.makeNixvimWithModule {
      inherit pkgs;
      module = {
        imports = modules;
      };
      extraSpecialArgs = specialArgs // {
        foodogsquaredModulesPath = builtins.toString nixvimModules;
      };
    };

  modulesOption = lib.mkOption {
    type = with lib.types; listOf deferredModule;
    default = [ ];
  };
  modulesOption' = configEnv: modulesOption // {
    description = ''
      A list of NixVim modules to be applied across all NixVim configurations
      when imported as part of ${configEnv}.
    '';
  };

  componentType = { lib, config, ... }: {
    imports = [
      ./shared/nixpkgs-options.nix
      (lib.mkAliasOptionModule [ "overlays" ] [ "nixpkgs" "overlays" ])
    ];

    options = {
      nixvimBranch = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "nixvim";
        example = "nixvim-unstable";
        description = ''
          The NixVim branch to be used for the NixVim configuration.

          It is recommend to match the NixVim branch with the nixpkgs branch.
          For example, a NixVim configuration of `nixos-24.05` should be paired
          with nixpkgs `nixos-24.05` branch.

          ::: {.note}
          This refers to your flake inputs so in order to support multiple
          NixVim branches, you need to import multiple NixVim branches as part
          of the `inputs` flake attribute.
          :::
        '';
      };

      neovimPackage = lib.mkOption {
        type = with lib.types; functionTo package;
        default = pkgs: pkgs.neovim;
        defaultText = "pkgs: pkgs.neovim";
        example = lib.literalExpression ''
          pkgs: pkgs.neovim-nightly
        '';
        description = ''
          The package to be used for the NixVim configuration. Since this is
          used per-system, it has to be a function returning a package from the
          given nixpkgs instance.
        '';
      };
    };

    config = {
      nixpkgs.config = cfg.sharedNixpkgsConfig;
    };
  };

  configType = { name, lib, config, ... }: {
    options = {
      components = lib.mkOption {
        type = with lib.types; listOf (submodule componentType);
        description = ''
          A list of specific components for the NixVim configuration to be
          built against.
        '';
        example = [
          { nixpkgsBranch = "nixos-unstable"; nixvimBranch = "nixvim-unstable"; }
          { nixpkgsBranch = "nixos-stable"; nixvimBranch = "nixvim-stable"; }
          { nixpkgsBranch = "nixos-stable"; nixvimBranch = "nixvim-stable"; neovimPackage = pkgs: pkgs.neovim-nightly; }
        ];
      };
    };

    config = {
      modules = [
        ../../../configs/nixvim/${config.configName}
      ];
    };
  };
in
{
  options.setups.nixvim = {
    configs = lib.mkOption {
      type = with lib.types; attrsOf (submoduleWith {
        specialArgs = { inherit (config) systems; };
        modules = [
          ./shared/config-options.nix
          configType
        ];
      });
      default = { };
      description = ''
        A set of NixVim configurations to be integrated into the declarative
        setups configuration. Each of them will be available as part of
        `nixvimConfigurations`.
      '';
    };

    sharedModules = modulesOption // {
      description = ''
        A list of NixVim modules to be shared across all of the NixVim
        configurations. This is also to be shared among wider-scoped
        environments when NixVim-specific integrations has been enabled.
      '';
    };
    standaloneConfigModules = modulesOption' "standalone configuration";

    sharedNixpkgsConfig = options.setups.sharedNixpkgsConfig // {
      description = ''
        nixpkgs configuration to be shared among the declared NixVim instances.
      '';
    };
  };

  config = lib.mkIf (cfg.configs != { }) {
    setups.nixvim.sharedNixpkgsConfig = config.setups.sharedNixpkgsConfig;

    setups.nixvim.sharedModules = [
      nixvimModules

      # Import our private modules.
      ../../nixvim/_private
    ];

    perSystem = { system, config, lib, ... }:
      (
        let
          validConfigs = lib.filterAttrs
            (_: metadata: lib.elem system metadata.systems)
            cfg.configs;

          nixvimConfigurations =
            let
              generateNixvimConfigs = name: metadata:
                let
                  mkNixvimConfig' = component:
                    let
                      pkgs = import inputs.${component.nixpkgsBranch} {
                        inherit (component.nixpkgs) config overlays;
                        inherit system;
                      };
                      neovimPackage = component.neovimPackage pkgs;
                    in
                    lib.nameValuePair
                      "${name}-${component.nixpkgsBranch}-${neovimPackage.pname}"
                      (mkNixvimConfig {
                        inherit system pkgs;
                        inherit (component) nixvimBranch;
                        modules =
                          cfg.sharedModules
                          ++ cfg.standaloneConfigModules
                          ++ metadata.modules
                          ++ [{ package = neovimPackage; }];
                      });
                  nixvimConfigs = builtins.map mkNixvimConfig' metadata.components;
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
