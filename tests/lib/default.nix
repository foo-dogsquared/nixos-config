# For the environment-specific subset, we'll be simulating the configurations
# as a simple attribute set since that's what they are anyways.
{ pkgs ? import <nixpkgs> { }, utils ? import ../utils.nix { inherit pkgs; } }:

let
  inherit (pkgs) lib;
  foodogsquaredLib = (import ../../lib { inherit pkgs; }).extend (final: prev:
  let
    callLib = file: import file { inherit pkgs lib; self = prev; };
  in
  {
    nixos = callLib ../../lib/env-specific/nixos.nix;
    home-manager = callLib ../../lib/env-specific/home-manager.nix;
    nixvim = callLib ../../lib/env-specific/nixvim.nix;
  });

  callLib = file: import file { inherit pkgs lib; self = foodogsquaredLib; };
in
{
  builders = callLib ./builders.nix;
  trivial = callLib ./trivial.nix;
  data = callLib ./data;
  math = callLib ./math.nix;

  # Environment-specific subset.
  home-manager = callLib ./home-manager.nix;
  nixos = callLib ./nixos.nix;
  nixvim = callLib ./nixvim.nix;
}
