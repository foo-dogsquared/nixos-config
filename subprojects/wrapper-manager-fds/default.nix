# The user entrypoint which makes it especially important to be maintained.
#
# Anyways, we just keep this attribute set for forward compatability in case it
# became required for users to pass something like the nixpkgs instance.
{ }:

{
  # Self-explanatory attributes, yeah? These are just integration modules for
  # the select environments...
  # ...such as for NixOS, ...
  nixosModules = rec {
    default = wrapper-manager;
    wrapper-manager = ./modules/env/nixos;
  };

  # ...and for home-manager.
  homeModules = rec {
    default = wrapper-manager;
    wrapper-manager = ./modules/env/home-manager;
  };

  # The main library interface that can be used for immediate consumption.
  lib = import ./lib/env.nix;

  # This is intended to be imported by the user in case they want to initialize
  # their own wrapper-manager library for whatever reason.
  wrapperManagerLib = ./lib;

  # The overlay that can be included in the nixpkgs instance which includes
  # only the wrapper-manager library set for now (and pretty much in the
  # distant future).
  overlays.default = final: prev: {
    wrapperManagerLib = import ./lib { pkgs = final; };
  };
}
