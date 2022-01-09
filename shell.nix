{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [ git git-crypt nixfmt rnix-lsp ];
}
