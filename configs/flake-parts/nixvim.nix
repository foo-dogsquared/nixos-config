{ lib, ... }:

{
  setups.nixvim = {
    configs.fiesta = {
      nixpkgsBranches = [
        "nixos-unstable"
        "nixpkgs-unstable"
      ];
      neovimPackages = pkgs: with pkgs; [
        neovim-nightly
      ];
    };
  };

  flake = {
    nixvimModules.default = ../../modules/nixvim;
  };
}
