{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  packages = [
    nixpkgs-fmt
    treefmt
  ];
}
