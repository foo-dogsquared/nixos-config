{ pkgs ? import <nixpkgs> { }, extraBuildInputs ? [ ], extraPackages ? [ ] }:

with pkgs;

mkShell {
  buildInputs = extraBuildInputs;

  packages = [
    # Formatters
    nixpkgs-fmt

    # Language servers
    rnix-lsp
  ] ++ extraPackages;
}
