{ pkgs ? import <nixpkgs> { } }:

let
  lib' = pkgs.lib.extend (import ./lib/extras/extend-lib.nix);
in
{
  lib = import ./lib { lib = pkgs.lib; };
  modules = lib'.importModules (lib'.filesToAttr ./modules/nixos);
  overlays = import ./overlays // {
    foo-dogsquared-pkgs = final: prev: import ./pkgs { pkgs = prev; };
  };
  hmModules = lib'.importModules (lib'.filesToAttr ./modules/home-manager);
} // (import ./pkgs { inherit pkgs; })
