{ config, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib) mkSubmoduleOptions mkPerSystemOption;
in
{
  options = {
    flake = mkSubmoduleOptions {
      devPackages = lib.mkOption {
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
        devPackages = lib.mkOption {
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
    flake.devPackages =
      lib.mapAttrs
        (k: v: v.devPackages)
        (lib.filterAttrs
          (k: v: v.devPackages != { })
          config.allSystems
        );

    perInput = system: flake:
      lib.optionalAttrs (flake ? devPackages.${system}) {
        devPackages = flake.devPackages.${system};
      };
  };
}
