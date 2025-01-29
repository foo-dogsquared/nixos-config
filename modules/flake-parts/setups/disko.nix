# A declarative setup for Disko scripts... Yeah, why not. Seriously though,
# this is only used to offer partitioning scripts for the rest of the system
# outside of NixOS even though we can easily write dedicated shell scripts for
# that. Take note we don't consider integrating this with declarative NixOS
# setups since their Disko scripts are already gettable in
# `config.system.build.diskoScript` along with its variants (e.g., `noDeps`).
{ config, lib, inputs, ... }:

let
  cfg = config.setups.disko;
  partsConfig = config;

  diskoConfigType = { name, config, ... }: {
    options = {
      configName = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = name;
        example = "plover";
        description = ''
          The name of the configuration to be used. Useful for creating variants
          of the same declarative environment.
        '';
      };
    };
  };
in {
  options.setups.disko = {
    configs = lib.mkOption {
      type = with lib.types; attrsOf (submodule diskoConfigType);
      default = { };
      example = { archive = { }; };
      description = ''
        A set of declarative Disko configurations only used for integrating
        with NixOS and itself by exporting into `diskoConfigurations` which is
        recognized by `disko` program.
      '';
    };
  };

  options.setups.nixos.configs = let
    diskoIntegrationModule = { config, lib, name, ... }: {
      options = {
        diskoConfigs = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          example = [ "external-hdd" ];
          description = ''
            A list of declarative Disko configurations to be included alongside
            the NixOS configuration.
          '';
        };
      };

      config = lib.mkIf (config.diskoConfigs != [ ]) (let
        diskoConfigs =
          builtins.map (name: "${partsConfig.setups.configDir}/disko/${name}")
          config.diskoConfigs;
      in {
        modules = lib.singleton {
          imports = [ inputs.disko.nixosModules.disko ] ++ diskoConfigs;
        };
      });
    };
  in lib.mkOption {
    type = with lib.types; attrsOf (submodule diskoIntegrationModule);
  };

  config = {
    flake.diskoConfigurations = lib.mapAttrs
      (name: _: import "${partsConfig.setups.configDir}/disko/${name}")
      cfg.configs;
  };
}
