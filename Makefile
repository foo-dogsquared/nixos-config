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
update:
	nix flake update --commit-lock-file --commit-lockfile-summary "flake.lock: update inputs"
