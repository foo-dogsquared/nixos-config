{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in
    {
      devShells = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                inputs.rust-overlay.overlays.default
              ];
            };
          in
          {
            default = import ./shell.nix { inherit pkgs; };
          });

      packages = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                inputs.rust-overlay.overlays.default
              ];
            };
          in
          {
            default = pkgs.callPackage ./. { };
          });
    };
}
