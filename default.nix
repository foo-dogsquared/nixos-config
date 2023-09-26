{ pkgs ? import <nixpkgs> { } }:

let
  lib' = pkgs.lib.extend (final: prev:
    import ./lib { lib = prev; } // import ./lib/private.nix { lib = final; });
in
{
  lib = import ./lib { lib = pkgs.lib; };
  modules = lib'.importModules (lib'.filesToAttr ./modules/nixos);
  overlays = import ./overlays // {
    foo-dogsquared-pkgs = final: prev: import ./pkgs { pkgs = prev; };
  };
  hmModules = lib'.importModules (lib'.filesToAttr ./modules/home-manager);
} // (import ./pkgs { inherit pkgs; })
