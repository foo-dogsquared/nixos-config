{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [ asciidoctor git git-crypt nixfmt rnix-lsp ];
}
