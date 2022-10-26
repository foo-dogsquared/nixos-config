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
	git checkout -- flake.lock
	nix flake update \
		--commit-lock-file --commit-lockfile-summary "flake.lock: update inputs"

.PHONY: update_with_forked_inputs
update_with_forked_inputs:
	nix flake lock \
		--override-input guix-overlay git+file:///home/foo-dogsquared/library/projects/software/nix-overlay-guix/ \
		--override-input dotfiles git+file:///home/foo-dogsquared/library/dotfiles/
