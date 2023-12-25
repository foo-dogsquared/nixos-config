{ pkgs ? import <nixpkgs> { } }:

let
  lib = pkgs.lib.extend (import ./lib/extras/extend-lib.nix);
in
{
  lib = import ./lib { lib = pkgs.lib; };
  modules.default.imports = import ./modules/nixos { inherit lib; };
  overlays = import ./overlays // rec {
    foo-dogsquared-pkgs = final: prev: import ./pkgs { pkgs = prev; };
    default = foo-dogsquared-pkgs;
  };
  hmModules.default.imports = import ./modules/home-manager { inherit lib; };
} // (import ./pkgs { inherit pkgs; })
