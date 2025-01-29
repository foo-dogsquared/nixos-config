{ config, lib, flake-parts-lib, ... }:

let inherit (flake-parts-lib) mkSubmoduleOptions mkPerSystemOption;
in {
  options = {
    flake = mkSubmoduleOptions {
      nixvimConfigurations = lib.mkOption {
        type = with lib.types; lazyAttrsOf (attrsOf package);
        default = { };
        description = ''
          An attribute set of per-system builds of
          [NixVim](https://github.com/nix-community/nixvim) configurations
          similar to `packages` flake output.
        '';
      };
    };

    perSystem = mkPerSystemOption {
      options = {
        nixvimConfigurations = lib.mkOption {
          type = with lib.types; attrsOf package;
          default = { };
          description = ''
            An attribute set of per-system builds of
            [NixVim](https://github.com/nix-community/nixvim) configurations
            similar to `packages` flake output.
          '';
        };
      };
    };
  };

  config = {
    flake.nixvimConfigurations = lib.mapAttrs (k: v: v.nixvimConfigurations)
      (lib.filterAttrs (k: v: v.nixvimConfigurations != { }) config.allSystems);

    perInput = system: flake:
      lib.optionalAttrs (flake ? nixvimConfigurations.${system}) {
        nixvimConfigurations = flake.nixvimConfigurations.${system};
      };
  };
}
