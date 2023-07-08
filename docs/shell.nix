{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  gems = bundlerEnv {
    name = "nixos-config-project-docs";
    ruby = ruby_3_1;
    gemdir = ./.;
  };
in
mkShell {
  packages = [
    gems
    gems.wrappedRuby
    bundix

    hugo
    go
    nodePackages.prettier
    vscode-langservers-extracted
  ];
}
