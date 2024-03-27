{ inputs
, lib
, config

, defaultOverlays

, ...
}:

let
  cfg = config.setups.nixvim;
  nixvimModules = ../../nixvim;

  mkNixvimConfig = { system, pkgs, modules ? [ ] }:
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
    type = with lib.types; listOf deferredModule;
    default = [ ];
  };
  modulesOption' = configEnv: modulesOption // {
    description = ''
      A list of NixVim modules to be applied across all NixVim configurations
      when imported as part of ${configEnv}.
    '';
  };

  configType = { name, lib, config, ... }: {
    options = {
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

      neovimPackages = lib.mkOption {
        type = with lib.types; functionTo (listOf package);
        default = pkgs: with pkgs; [ neovim ];
        defaultText = "pkgs: with pkgs; [ neovim ]";
        example = lib.literalExpression ''
          pkgs: with pkgs; [
            (wrapNeovim neovim-unwrapped { })
            neovim-nightly
            neovide
          ]
        '';
        description = ''
          A list of Neovim packages from different branches to be built
          against. Since this is to be used per-system, it should be a function
          that returns a list of packages where the given statement is the
          nixpkgs instance.
        '';
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
        configurations.
      '';
    };
    standaloneConfigModules = modulesOption' "standalone configuration";
  };

  config = lib.mkIf (cfg.configs != { }) {
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
                  iterateThruBranches = nixpkgsBranch:
                    let
                      pkgs = import inputs.${nixpkgsBranch} {
                        inherit system;
                        overlays = defaultOverlays ++ [
                          inputs.neovim-nightly-overlay.overlays.default
                        ];
                        config.allowUnfree = true;
                      };

                      neovimPackages = metadata.neovimPackages pkgs;

                      mkNixvimConfig' = neovimPkg:
                        lib.nameValuePair
                          "${name}-${nixpkgsBranch}-${neovimPkg.name}"
                          (mkNixvimConfig {
                            inherit system pkgs;
                            modules =
                              cfg.sharedModules
                              ++ cfg.standaloneConfigModules
                              ++ metadata.modules
                              ++ [{ package = neovimPkg; }];
                          });
                    in
                    builtins.map mkNixvimConfig' neovimPackages;

                  nixvimConfigs = lib.lists.flatten
                    (builtins.map iterateThruBranches metadata.nixpkgsBranches);
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
