{ pkgs ? import <nixpkgs> { }, extraPackages ? [ ] }:

pkgs.mkShell {
  packages = with pkgs; [
    age
    asciidoctor
    deploy-rs
    home-manager
    git
    sops

    bind
    opentofu

    jq
    wl-clipboard

    # Language servers for various parts of the config that uses a language.
    lua-language-server
    pyright
    nil
    terraform-ls

    # Formatters...
    treefmt # The universal formatter (if you configured it).
    stylua # ...for Lua.
    black # ...for Python.
    nixpkgs-fmt # ...for Nix.
  ] ++ extraPackages;
}
