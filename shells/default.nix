{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  flatpak = callPackage ./flatpak.nix { };
  gnu = callPackage ./gnu.nix { };
  gnome = callPackage ./gnome.nix { };
  nix = callPackage ./nix.nix { };
  hugo = callPackage ./hugo.nix { };
  rust = callPackage ./rust.nix { };
  tic-80 = callPackage ./tic-80.nix { };
}
