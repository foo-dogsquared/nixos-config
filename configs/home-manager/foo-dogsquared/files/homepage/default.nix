{ pkgs ?
  import <nixpkgs> { overlays = [ (import ../../../../../overlays).default ]; }
}:

pkgs.callPackage ./package.nix { }
