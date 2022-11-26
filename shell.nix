{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [
    asciidoctor
    age
    git
    jq
    nixpkgs-fmt
    sops
    treefmt
    deploy-rs

    # Language servers for various parts of the config that uses a language.
    sumneko-lua-language-server
    pyright
    rnix-lsp

    # Formatters...
    stylua # ...for Lua.
    black # ...for Python.
    nixpkgs-fmt # ...for Nix.
  ];
}
