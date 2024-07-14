let
  sources = import ./npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  websiteDevshell = import ./docs/shell.nix { inherit pkgs; };
in
pkgs.mkShell {
  packages = with pkgs; [
    websiteDevshell

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
