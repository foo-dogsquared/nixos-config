{ pkgs ? import <nixpkgs> { overlays = [ (import ../../overlays).default ]; } }:

let site = pkgs.callPackage ./package.nix { };
in pkgs.mkShell {
  inputsFrom = [ site ];

  packages = with pkgs; [
    bundix

    nodePackages.prettier
    vscode-langservers-extracted
  ];
}
