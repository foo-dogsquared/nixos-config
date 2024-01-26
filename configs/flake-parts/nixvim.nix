{ lib, ... }:

{
  setups.nixvim = {
    configs.fiesta = {
      nixpkgsBranches = [
        "nixos-unstable"
        "nixos-stable"
      ];
    };
  };

  flake = {
    nixvimModules.default = ../../modules/nixvim;
  };
}
