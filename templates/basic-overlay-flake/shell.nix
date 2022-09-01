{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  packages = [
    rnix-lsp
    nixpkgs-fmt
  ];
}
