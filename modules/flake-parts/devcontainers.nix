{ config, lib, flake-parts-lib, ... }:

let inherit (flake-parts-lib) mkSubmoduleOptions mkPerSystemOption;
in {
  options = {
    flake = mkSubmoduleOptions {
      devContainers = lib.mkOption {
        type = with lib.types; lazyAttrsOf (attrsOf package);
        default = { };
        description = ''
          An attribute set of per-system packages intended to be consumed for
          development environments.
        '';
      };
    };

    perSystem = mkPerSystemOption {
      options = {
        devContainers = lib.mkOption {
          type = with lib.types; attrsOf package;
          default = { };
          description = ''
            An attribute set of per-system packages intended to be consumed for
            development environments.
          '';
        };
      };
    };
  };

  config = {
    flake.devContainers = lib.mapAttrs (k: v: v.devContainers)
      (lib.filterAttrs (k: v: v.devContainers != { }) config.allSystems);

    perInput = system: flake:
      lib.optionalAttrs (flake ? devContainers.${system}) {
        devContainers = flake.devContainers.${system};
      };
  };
}
