{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  cloud = callPackage ./cloud.nix { };
  creatives = callPackage ./creatives.nix { };
  flatpak = callPackage ./flatpak.nix { };
  gnu = callPackage ./gnu.nix { };
  gnome = callPackage ./gnome.nix { };
  nix = callPackage ./nix.nix { };
  nodejsStable = callPackage ./nodejs.nix { };
  nodejsLatest = callPackage ./nodejs.nix { nodejs = nodejs_latest; };
  go = callPackage ./go.nix { };
  guile = callPackage ./guile.nix { };
  guile2 = callPackage ./guile.nix { guile = guile_2_2; };
  gtk3 = callPackage ./gtk.nix {
    gtk = gtk3;
    libportal-gtk = libportal-gtk3;
  };
  gtk4 = callPackage ./gtk.nix {
    gtk = gtk4;
    wrapGAppsHook = wrapGAppsHook4;
    libportal-gtk = libportal-gtk4;
  };
  hugo = callPackage ./hugo.nix { };
  latex = callPackage ./latex.nix { };
  lua_5_2 = callPackage ./lua.nix { lua = lua52Packages.lua; };
  lua_5_3 = callPackage ./lua.nix { lua = lua53Packages.lua; };
  rust = callPackage ./rust.nix { };
  tic-80 = callPackage ./tic-80.nix { };
}
