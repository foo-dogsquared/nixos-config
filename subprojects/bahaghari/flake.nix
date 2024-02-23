{
  description = "Specialized set of Nix modules for generating and applying themes.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let systems = inputs.flake-utils.lib.defaultSystems;
    in inputs.flake-utils.lib.eachSystem systems (system: {
      devShells.default =
        import ./shell.nix { pkgs = import nixpkgs { inherit system; }; };
    }) // {
      nixosModules = {
        "bahaghari/tinted-theming" = ./modules/tinted-theming;
      };

      homeModules = {
        "bahaghari/tinted-theming" = ./modules/tinted-theming;
      };

      nixvimModules = {
        "bahaghari/tinted-theming" = ./modules/tinted-theming;
      };

      bahaghariLib = ./lib;
    };
}
