{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  ffof = callPackage ./package.nix { };
in
mkShell {
  inputsFrom = [ ffof ];

  packages = [
    gopls
    delve
  ];
}
