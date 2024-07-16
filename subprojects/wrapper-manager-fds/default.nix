# The user entrypoint which makes it especially important to be maintained.
#
# Anyways, we just keep this attribute set for forward compatability in case it
# became required for users to pass something like the nixpkgs instance.
{ }:

{
  nixosModules = rec {
    default = wrapper-manager;
    wrapper-manager = ./modules/env/nixos;
  };

  homeModules = rec {
    default = wrapper-manager;
    wrapper-manager = ./modules/env/home-manager;
  };

  lib = import ./lib/env.nix;
  wrapperManagerLib = ./lib;
}
