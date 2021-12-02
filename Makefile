ROOT := /mnt
HOST := ni

.PHONY: install
install:
	nixos-install --flake ".#${HOST}" --root ${ROOT}

.PHONY: switch
switch:
	nixos-rebuild --flake ".#${HOST}" switch

.PHONY: test
test:
	nixos-rebuild --flake ".#${HOST}" dry-activate

.PHONY: update
	nix flake update
