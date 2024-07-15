let
  sources = import ../npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  inherit (pkgs) nixosOptionsDoc;
  websitePkg = import ./. { inherit pkgs; };
  wrapperManagerLib = import ../lib/env.nix;

  wrapperManagerEval = wrapperManagerLib.eval { inherit pkgs; };
  optionsDoc = nixosOptionsDoc { inherit (wrapperManagerEval) options; };
in
with pkgs; mkShell {
  inputsFrom = [ websitePkg ];

  packages = [
    nodePackages.prettier
    vscode-langservers-extracted
  ];

  shellHook = ''
    install -Dm0644 ${optionsDoc.optionsJSON}/share/doc/nixos/options.json ./content/en-US/nix-module-options/module-environment/content.json
  '';
}
