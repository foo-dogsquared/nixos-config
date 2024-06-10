{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = {
    home-manager = import ./modules/home-manager { inherit pkgs; };
  };
}
