{ lib, ... }:

{
  setups.nixvim = {
    configs.fiesta = {
      nixpkgsBranches = [
        "nixos-unstable"
        "nixpkgs-unstable"
      ];
    };
  };

  flake = {
    nixvimModules.default = ../../modules/nixvim;
  };
}
