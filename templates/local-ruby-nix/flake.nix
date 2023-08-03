{
  description = "Basic flake template for setting up development shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    ruby-nix.url = "github:sagittaros/ruby-nix";
    ruby-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ruby-nix, nixpkgs, ... }:
    let systems = inputs.flake-utils.lib.defaultSystems;
    in inputs.flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default =
          import ./shell.nix { inherit pkgs ruby-nix; };

        formatter = pkgs.treefmt;
      });
}
