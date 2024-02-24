# This is the unit cases for our Nix project.
{ pkgs ? import <nixpkgs> { } }:


{
  lib = import ./lib { inherit pkgs; };
  #modules = import ./modules { inherit pkgs; };
}
