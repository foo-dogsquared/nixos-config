{ pkgs }:

let
  lib = import ../../lib { inherit pkgs; };
in
{
  hex = import ./hex.nix { inherit pkgs lib; };
  trivial = import ./trivial { inherit pkgs lib; };
  tinted-theming = import ./tinted-theming { inherit pkgs lib; };
}
