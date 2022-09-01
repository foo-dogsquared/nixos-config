{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  flatpak = callPackage ./flatpak.nix { };
  gnu = callPackage ./gnu.nix { };
  gnome = callPackage ./gnome.nix { };
  nix = callPackage ./nix.nix { };
  guile = callPackage ./guile.nix { };
  guile3 = callPackage ./guile.nix { guile = guile_3_0; };
  hugo = callPackage ./hugo.nix { };
  rust = callPackage ./rust.nix { };
  tic-80 = callPackage ./tic-80.nix { };
}
