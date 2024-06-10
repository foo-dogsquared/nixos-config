{ inputs, ... }:

{
  setups.nixvim.configs = {
    fiesta = {
      nixpkgsBranches = [
        "nixos-unstable"
      ];
      nixvimBranch = "nixvim-unstable";
      neovimPackages = p: with p; [
        neovim
      ];
    };

    trovebelt = {
      nixpkgsBranches = [
        "nixos-unstable"
      ];
      nixvimBranch = "nixos-unstable";
      neovimPackages = p: with p; [
        neovim
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
