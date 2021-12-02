{ pkgs ? import <nixpkgs> { } }:

{
  doggo = pkgs.callPackage ./doggo.nix { };
  gnome-shell-extension-pop-shell = pkgs.callPackage ./gnome-shell-extension-pop-shell.nix { };
  libcs50 = pkgs.callPackage ./libcs50.nix { };
  tic-80 = pkgs.callPackage ./tic-80.nix { };
}
