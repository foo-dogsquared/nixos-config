{ inputs, ... }:

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

  setups.nixvim.sharedModules = [
    # The rainbow road to ricing your raw materials.
    inputs.self.nixvimModules.bahaghari
  ];

  flake = {
    nixvimModules.default = ../../modules/nixvim;
  };
}
