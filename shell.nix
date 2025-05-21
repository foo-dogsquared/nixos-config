{ pkgs ? import <nixpkgs> { }, extraPackages ? [ ] }:

let
  run-workflow-in-vm = pkgs.callPackage ./apps/run-workflow-with-vm { };
  fetch-website-icon = pkgs.callPackage ./lib/fetchers/fetch-website-icon/package/package.nix { };
  fds-flock-of-fetchers = pkgs.callPackage ./apps/fds-fetcher-flock/nix/package.nix { };
in pkgs.mkShell {
  packages = with pkgs;
    [
      # My internal applications.
      run-workflow-in-vm
      fetch-website-icon
      fds-flock-of-fetchers

      just
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
      nixdoc

      bind
      opentofu

      # The typical scripting toolkit.
      go
      jq
      wl-clipboard

      # Language servers for various parts of the config that uses a language.
      lua-language-server
      pyright
      nil
      terraform-ls
      gopls

      # Formatters...
      treefmt # The universal formatter (if you configured it).
      stylua # ...for Lua.
      black # ...for Python.
      nixfmt # ...for Nix.

      # Debuggers...
      delve
    ] ++ extraPackages;
}
