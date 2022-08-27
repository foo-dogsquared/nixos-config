{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [ asciidoctor age git jq nixpkgs-fmt rnix-lsp sops ];
}
