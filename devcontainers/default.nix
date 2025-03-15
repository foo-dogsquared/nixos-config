{ pkgs ? import <nixpkgs> { overlays = [ (import ../overlays).default ]; } }:

let inherit (pkgs) callPackage;
in {
  rustBackend = callPackage ./rust-backend.nix { };
  jsBackend = callPackage ./js-backend.nix { };
  ruby_3_2 = callPackage ./ruby-on-rails.nix { ruby = pkgs.ruby_3_2; };
  ruby_3_3 = callPackage ./ruby-on-rails.nix { ruby = pkgs.ruby_3_3; };
  ruby_3_4 = callPackage ./ruby-on-rails.nix { ruby = pkgs.ruby_3_4; };
}
