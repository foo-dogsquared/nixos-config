# This is the unit cases for our Nix project.
{ branch ? "nixos-stable" }:

let
  sources = import ../npins;
  pkgs = import sources.${branch} { };
in
{
  lib = import ./lib { inherit pkgs; };
  #modules = import ./modules { inherit pkgs; };
}
