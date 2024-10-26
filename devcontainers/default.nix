{ pkgs ? import <nixpkgs> { } }:

let inherit (pkgs) callPackage;
in {
  rustBackend = callPackage ./rust-backend.nix { };
  jsBackend = callPackage ./js-backend.nix { };
}
