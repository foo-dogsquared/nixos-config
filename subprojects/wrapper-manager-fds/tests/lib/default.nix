{ pkgs }:

let
  lib = import ../../lib { inherit pkgs; };
  callLib =
    file:
    import file {
      inherit (pkgs) lib;
      inherit pkgs;
      self = lib;
    };
in
{
  env = callLib ./env;
  utils = callLib ./utils.nix;
}
