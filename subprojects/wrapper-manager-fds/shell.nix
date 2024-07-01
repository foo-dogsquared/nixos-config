{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  inputsFrom = with pkgs; [ nix ];
  packages = with pkgs; [
    npins
    treefmt
    nixpkgs-fmt
  ];
}
