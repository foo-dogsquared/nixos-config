{
  description = "Basic flake template for setting up development shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    ruby-nix.url = "github: inscapist/ruby-nix";
    ruby-nix.inputs.nixpkgs.follows = "nixpkgs";

    ruby-nix-bundix.url = "github:inscapist/bundix";
    ruby-nix-bundix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ruby-nix, nixpkgs, ... }:
    let systems = inputs.flake-utils.lib.defaultSystems;
    in inputs.flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        gems = ruby-nix.lib pkgs {
          name = "ruby-nix-env";
          ruby = pkgs.ruby_3_1;
          gemset = ./gemset.nix;
        };
      in {
        devShells.default = import ./shell.nix {
          inherit pkgs;
          extraBuildInputs = [ gems.env gems.ruby ];
          extraPackages =
            [ inputs.ruby-nix-bundix.packages."${system}".default ];
        };

        formatter = pkgs.treefmt;
      });
}
