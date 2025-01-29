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
    ./wrapper-manager.nix
  ];

  options.setups = {
    configDir = lib.mkOption {
      type = lib.types.path;
      default = ../../../configs;
      description = ''
        The directory containing configurations of various environments. The
        top-level directories are expected to be the name of the environment
        with their configurations inside.
      '';
      example = lib.literalExpression ''
        ''${inputs.my-flake}/configs
      '';
    };

    sharedNixpkgsConfig = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        Shared configuration of the nixpkgs instance to be passed to all of the
        module environments based from the nixpkgs module system.
      '';
      default = { };
      example = { allowUnfree = true; };
    };

    sharedSpecialArgs = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        Shared set of arguments to be assigned as part of `_module.specialArgs`
        of each of the declarative setups.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          location = "Inside of your walls";
          utilsLib = import ./lib/utils.nix;
        }
      '';
    };
  };
}
