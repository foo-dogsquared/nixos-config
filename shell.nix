{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [ asciidoctor age git nixpkgs-fmt rnix-lsp sops ];
}
