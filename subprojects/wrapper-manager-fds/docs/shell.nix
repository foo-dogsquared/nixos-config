let
  sources = import ../npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  websitePkg = import ./. { inherit pkgs; };
in
with pkgs; mkShell {
  inputsFrom = [ websitePkg ];

  packages = [
    nodePackages.prettier
    vscode-langservers-extracted
  ];
}
