let
  sources = import ./npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

pkgs.mkShell {
  packages = with pkgs; [
    npins
    treefmt
    nixpkgs-fmt

    hugo
    asciidoctor

    # For easy validation of the test suite.
    yajsv
    jq
  ];
}
