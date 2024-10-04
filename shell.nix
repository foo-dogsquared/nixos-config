{ pkgs ? import <nixpkgs> { }, extraPackages ? [ ] }:

let
  run-workflow-in-vm = pkgs.callPackage ./apps/run-workflow-with-vm { };
in
pkgs.mkShell {
  packages = with pkgs; [
    # My internal applications.
    run-workflow-in-vm

    age
    asciidoctor
    disko
    deploy-rs
    hcloud
    npins
    nixos-anywhere
    home-manager
    git
    sops
    nix-update

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
    nixfmt # ...for Nix.
  ] ++ extraPackages;
}
