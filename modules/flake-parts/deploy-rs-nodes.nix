{ lib, flake-parts-lib, ... }:

let
  deployType = { config, lib, pkgs, ... }: {
    options.nodes = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        A set of deploy-rs nodes.
      '';
    };
  };
in {
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      deploy = lib.mkOption {
        type = with lib.types; submodule deployType;
        default = { };
        description = ''
          An attribute set of deploy-rs nodes
        '';
      };
    };
  };
}
