{ inputs, lib, ... }:

{
  setups.nixvim.configs = {
    fiesta = {
      components = [{
        nixpkgsBranch = "nixos-unstable";
        nixvimBranch = "nixvim-unstable";
        neovimPackage = pkgs: pkgs.neovim;
        overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
      }];
    };

    trovebelt = {
      components = lib.cartesianProduct {
        nixpkgsBranch = [ "nixos-unstable" ];
        nixvimBranch = [ "nixvim-unstable" ];
        neovimPackage = [ (pkgs: pkgs.neovim) ];
        overlays = [ [ inputs.neovim-nightly-overlay.overlays.default ] [ ] ];
      };
    };
  };

  setups.nixvim.sharedModules = [
    # The rainbow road to ricing your raw materials.
    inputs.self.nixvimModules.bahaghari
  ];

  flake = { nixvimModules.default = ../../modules/nixvim; };
}
