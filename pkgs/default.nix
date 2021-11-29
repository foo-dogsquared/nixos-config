{ pkgs ? <nixpkgs> }:

{
  libcs50 = pkgs.callPackage ./libcs50.nix { };
}
