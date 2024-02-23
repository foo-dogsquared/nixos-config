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
    # Setting up Bahaghari.
    ({ config, lib, pkgs, ... }: {
      imports = [ inputs.self.nixvimModules."bahaghari/tinted-theming" ];

      _module.args.bahaghariLib =
        import inputs.self.bahaghariLib { inherit pkgs; };
    })
  ];

  flake = {
    nixvimModules.default = ../../modules/nixvim;
  };
}
