{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  inputsFrom = [ nix ];
}
