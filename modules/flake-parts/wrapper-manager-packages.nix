# A flake-parts module containing definition for my custom wrapper-manager
# packages which should have its own flake output attribute at
# `wrapperManagerPackages` containing the derivations that can be run or build.
{ config, lib, flake-parts-lib, ... }:

let inherit (flake-parts-lib) mkSubmoduleOptions mkPerSystemOption;
in {
  options = {
    flake = mkSubmoduleOptions {
      wrapperManagerPackages = lib.mkOption {
        type = with lib.types; lazyAttrsOf (attrsOf package);
        default = { };
        description = ''
          An attribute set of per-system wrapper-manager configurations.
        '';
      };
    };

    perSystem = mkPerSystemOption {
      options = {
        wrapperManagerPackages = lib.mkOption {
          type = with lib.types; attrsOf package;
          default = { };
          description = ''
            An attribute set of wrapper-manager configurations.
          '';
        };
      };
    };
  };

  config = {
    flake.wrapperManagerPackages = lib.mapAttrs (k: v: v.wrapperManagerPackages)
      (lib.filterAttrs (k: v: v.wrapperManagerPackages != { })
        config.allSystems);

    perInput = system: flake:
      lib.optionalAttrs (flake ? wrapperManagerPackages.${system}) {
        wrapperManagerPackages = flake.wrapperManagerPackages.${system};
      };
  };
}
