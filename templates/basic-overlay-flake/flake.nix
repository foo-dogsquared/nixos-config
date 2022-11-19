{
  description = ''
    Basic flake template for an overlay with flake.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      inherit (inputs.flake-utils.lib) defaultSystems eachSystem flattenTree;
    in
    eachSystem defaultSystems
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          devShells.default =
            import ./shell.nix { inherit pkgs; };

          formatter = pkgs.nixpkgs-fmt;

          packages = flattenTree (self.overlays.default pkgs pkgs);
        }) // {
      overlays.default = final: prev: import ./pkgs { pkgs = prev; };

      nixosModules = { };
    };
}
