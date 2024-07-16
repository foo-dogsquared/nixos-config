# The declarative environment management modules. Basically the backbone of my
# flake. Most of the modules here should have some things integrated within
# each other such as the ability to easily declare home-manager users (or a
# NixVim instance) into a NixOS system from already existing declared
# home-manager users (or NixVim instances) in the flake config.
{ lib, ... }:

{
  imports = [
    ./disko.nix
    ./nixos.nix
    ./nixvim.nix
    ./home-manager.nix
  ];

  options.setups.sharedNixpkgsConfig = lib.mkOption {
    type = with lib.types; attrsOf anything;
    description = ''
      Shared configuration of the nixpkgs instance to be passed to all of the
      module environments based from the nixpkgs module system.
    '';
    default = { };
    example = {
      allowUnfree = true;
    };
  };
}
