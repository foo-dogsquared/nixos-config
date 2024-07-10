# For the environment-specific subset, we'll be simulating the configurations
# as a simple attribute set since that's what they are anyways.
{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib;
  foodogsquaredLib = (import ../../lib { inherit pkgs; }).extend (final: prev:
  let
    callLib = file: import file { inherit pkgs lib; self = prev; };
  in
  {
    nixos = callLib ../../lib/nixos.nix;
    home-manager = callLib ../../lib/home-manager.nix;
    nixvim = callLib ../../lib/nixvim.nix;
  });

  callLib = file: import file { inherit pkgs lib; self = foodogsquaredLib; };
in
{
  builders = callLib ./builders.nix;
  trivial = callLib ./trivial.nix;
  data = callLib ./data;

  # Environment-specific subset.
  home-manager = callLib ./home-manager.nix;
  nixos = callLib ./nixos.nix;
  nixvim = callLib ./nixvim.nix;
}
