# The baseline configuration for all of the setup type in this cluster. Take
# note this is also exported as a flake-parts module to be easily used in
# private configurations.
{ lib, ... }:

let
  homeManagerModules = ../../modules/home-manager;
  nixosModules = ../../modules/nixos;
  nixvimModules = ../../modules/nixvim;
  wrapperManagerModules = ../../modules/wrapper-manager;
in {
  setups.home-manager = {
    sharedSpecialArgs = {
      foodogsquaredModulesPath = builtins.toString homeManagerModules;
    };
    sharedModules = [
      homeManagerModules
      ../../modules/home-manager/_private
    ];
  };

  setups.nixos = {
    sharedSpecialArgs = {
      foodogsquaredUtils =
        import ../../lib/utils/nixos.nix { inherit lib; };
        foodogsquaredModulesPath = builtins.toString nixosModules;
    };
    sharedModules = [
      nixosModules
      ../../modules/nixos/_private
    ];
  };

  setups.nixvim = {
    sharedSpecialArgs = {
      foodogsquaredModulesPath = builtins.toString nixvimModules;
    };
    sharedModules = [
      nixvimModules
      ../../modules/nixvim/_private
    ];
  };

  setups.wrapper-manager = {
    sharedSpecialArgs = {
      foodogsquaredModulesPath = builtins.toString wrapperManagerModules;
    };
    sharedModules = [
      wrapperManagerModules
      ../../modules/wrapper-manager/_private
    ];
  };
}
