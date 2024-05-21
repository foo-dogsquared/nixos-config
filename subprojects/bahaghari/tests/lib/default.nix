{ pkgs }:

let
  lib = import ../../lib { inherit pkgs; };
  callLib = file: import file {
    inherit (pkgs) lib; inherit pkgs;
    self = lib;
  };
in
{
  hex = callLib ./hex.nix;
  math = callLib ./math.nix;
  trivial = callLib ./trivial;
  tinted-theming = callLib ./tinted-theming;
  rgb = callLib ./rgb.nix;
}
