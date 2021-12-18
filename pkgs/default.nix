{ pkgs ? import <nixpkgs> { } }:

{
  doggo = pkgs.callPackage ./doggo.nix { };
  gnome-shell-extension-pop-shell =
    pkgs.callPackage ./gnome-shell-extension-pop-shell.nix { };
  libcs50 = pkgs.callPackage ./libcs50.nix { };
  pop-launcher = pkgs.callPackage ./pop-launcher.nix { };
  gnome-shell-extension-fly-pie =
    callPackage ./gnome-shell-extension-fly-pie.nix { };
  pop-launcher-plugin-duckduckgo-bangs =
    pkgs.callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
  tic-80 = pkgs.callPackage ./tic-80.nix { };
  sioyek = libsForQt5.callPackage ./sioyek.nix { };
}
