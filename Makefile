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

# The overridden inputs are just the inputs I typically use with my own
# fork so we'll have to create a way to seamlessly upgrade those specific
# inputs. Fortunately for us, this is possible with Nix command line
# interface.
#
# Because of the nature to use my own fork, when to update is an important
# thing to consider.
.PHONY: update
update:
	git checkout -- flake.lock
	nix flake update \
		--override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable \
		--override-input guix-overlay github:foo-dogsquared/nix-overlay-guix \
		--override-input home-manager github:nix-community/home-manager \
		--commit-lock-file --commit-lockfile-summary "flake.lock: update inputs"
