default:
    just --list

update:
    git checkout -- flake.lock
    nix flake update --commit-lock-file

# Update a package with nix-update.
pkg-update PKG:
    nix-update -f pkgs {{PKG}}

# Build a package from `pkgs/` folder.
pkg-build PKG:
    nix-build pkgs -A {{PKG}}

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
deploy-nixos HOST:
    deploy '.#nixos-${HOST}' --skip-checks
