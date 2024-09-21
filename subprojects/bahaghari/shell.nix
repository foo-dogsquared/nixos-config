let
  sources = import ./npins;
in
{ pkgs ? import sources.nixos-stable { } }:

with pkgs;

mkShell {
  inputsFrom = [
    nix
  ];

  packages = [
    npins

    treefmt
    nixfmt-rfc-style
  ];
}
