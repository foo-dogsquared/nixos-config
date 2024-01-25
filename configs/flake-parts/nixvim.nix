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
}
