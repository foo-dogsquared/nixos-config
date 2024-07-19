let
  sources = import ./npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  websitePkg = import ./docs { inherit pkgs; };
in
pkgs.mkShell {
  inputsFrom = [ websitePkg ];

  packages = with pkgs; [
    npins
    treefmt
    nixpkgs-fmt

    # For easy validation of the test suite.
    yajsv
    jq
  ];
}
