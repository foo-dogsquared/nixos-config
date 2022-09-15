{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  flatpak = callPackage ./flatpak.nix { };
  gnu = callPackage ./gnu.nix { };
  gnome = callPackage ./gnome.nix { };
  nix = callPackage ./nix.nix { };
  guile = callPackage ./guile.nix { };
  guile3 = callPackage ./guile.nix { guile = guile_3_0; };
  gtk3 = callPackage ./gtk.nix { gtk = gtk3; libportal-gtk = libportal-gtk3; };
  gtk4 = callPackage ./gtk.nix { gtk = gtk4; wrapGAppsHook = wrapGAppsHook4; libportal-gtk = libportal-gtk4; };
  hugo = callPackage ./hugo.nix { };
  rust = callPackage ./rust.nix { };
  tic-80 = callPackage ./tic-80.nix { };
}
