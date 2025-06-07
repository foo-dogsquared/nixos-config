default:
    just --list

# Update the flake lockfile.
update:
    git checkout -- flake.lock
    nix flake update --commit-lock-file

# Small wrapper around nixos-rebuild.
host-build HOST *ARGS:
    nixos-rebuild --flake '.#{{HOST}}-{{arch()}}-{{os()}}' {{ARGS}}

# Small wrapper for installing NixOS systems.
nixos-install HOST *ARGS:
    disko-install --flake '.#{{HOST}}-{{arch()}}-{{os()}}' {{ARGS}}

# Update a package with nix-update.
pkg-update PKG *ARGS:
    nix-update -f pkgs {{PKG}} {{ARGS}}

# Build a package from `pkgs/` folder.
pkg-build PKG *ARGS:
    nix-build pkgs -A {{PKG}} {{ARGS}}

# Build Firefox addons.
pkg-build-firefox-addons:
    mozilla-addons-to-nix ./pkgs/firefox-addons/firefox-addons.json ./pkgs/firefox-addons/default.nix

# Live server for project website.
docs-serve:
    hugo -s ./docs serve

# Build the project website.
docs-build:
    hugo -s ./docs/

# Deploy NixOS system.
deploy-nixos HOST *ARGS:
    deploy '.#nixos-{{HOST}}' --skip-checks {{ARGS}}

# Deploy home environment.
deploy-hm USER *ARGS:
    deploy '.#home-manager-{{USER}}' --skip-checks {{ARGS}}

# Build NixVim configurations.
nixvim-build INSTANCE *ARGS:
    nix build .#nixvimConfigurations.{{arch()}}.{{INSTANCE}} {{ARGS}}

# Run NixVim configurations.
nixvim-run INSTANCE *ARGS:
    nix run .#nixvimConfigurations.{{arch()}}.{{INSTANCE}} {{ARGS}}
