{ pkgs }:

let
  lib = import ../../lib { inherit pkgs; };
in
{
  trivial = import ./trivial { inherit pkgs lib; };
  tinted-theming = import ./tinted-theming { inherit pkgs lib; };
}
