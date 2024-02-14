{ ... }:

{
  setups.nixvim.configs = {
    fiesta = {
      nixpkgsBranches = [
        "nixos-unstable"
      ];
      neovimPackages = p: with p; [
        neovim-nightly
      ];
    };

    trovebelt = {
      nixpkgsBranches = [
        "nixos-unstable"
      ];
      neovimPackages = p: with p; [
        neovim-nightly
      ];
    };
  };

  flake = {
    nixvimModules.default = ../../modules/nixvim;
  };
}
