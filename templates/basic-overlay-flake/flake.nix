{
  description = ''
    Basic flake template for an overlay with flake and traditional channels.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let systems = inputs.flake-utils.lib.defaultSystems;
    in inputs.flake-utils.lib.eachSystem systems (system: {
      devShells.default =
        import ./shell.nix { pkgs = import nixpkgs { inherit system; }; };
    });
}
