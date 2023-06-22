{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [
    age
    asciidoctor
    deploy-rs
    git
    sops
    terraform

    jq
    wl-clipboard

    # Language servers for various parts of the config that uses a language.
    lua-language-server
    pyright
    rnix-lsp
    terraform-ls

    # Formatters...
    treefmt # The universal formatter (if you configured it).
    stylua # ...for Lua.
    black # ...for Python.
    nixpkgs-fmt # ...for Nix.
  ];
}
