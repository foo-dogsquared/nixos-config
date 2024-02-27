# A declarative setup for Disko scripts... Yeah, why not. Seriously though,
# this is only used to offer partitioning scripts for the rest of the system
# outside of NixOS even though we can easily write dedicated shell scripts for
# that. Take note we don't consider integrating this with declarative NixOS
# setups since their Disko scripts are already gettable in
# `config.system.build.diskoScript` along with its variants (e.g., `noDeps`).
{ config, lib, ... }:

let
  cfg = config.setups.disko;

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
in
{
  options.setups.disko = {
    configs = lib.mkOption {
      type = with lib.types; attrsOf (submodule diskoConfigType);
      default = { };
      example = {
        archive = { };
      };
      description = ''
        A set of declarative Disko configurations only used for integrating
        with NixOS and itself by exporting into `diskoConfigurations` which is
        recognized by `disko` program.
      '';
    };
  };

  config = {
    flake.diskoConfigurations =
      lib.mapAttrs (name: _: import ../../../configs/disko/${name}) cfg.configs;
  };
}
