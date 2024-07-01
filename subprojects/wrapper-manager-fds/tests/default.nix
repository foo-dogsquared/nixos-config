{ branch ? "nixos-stable" }:

let
  sources = import ../npins;
  pkgs = import sources.${branch} { };
in
{
  lib = import ./lib { inherit pkgs; };
}
