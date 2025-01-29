{ pkgs ? import <nixpkgs> { } }:

let app = pkgs.callPackage ./. { };
in pkgs.mkShell {
  inputsFrom = [ app ];

  packages = with pkgs; [ git clang-tools ];
}
