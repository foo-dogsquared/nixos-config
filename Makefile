USER	:= foo-dogsquared
HOST	:= zilch
HOME	:= /home/$(USER)
DOTS	:= /etc/dotfiles

NIXOS_VERSION	:= 20.03
NIXOS_PREFIX	:= $(PREFIX)/etc/nixos
FLAGS		:= -I "config=$$(pwd)/config" \
		-I "modules=$$(pwd)/modules" \
		-I "bin=$$(pwd)/bin" \
		$(FLAGS)

config:	$(NIXOS_PREFIX)/configuration.nix
home:	$(HOME)/dotfiles

# The channels will be used on certain modules like in `packages/default.nix` where it will be referred to install certain packages from the unstable channel.
channels:
	@sudo nix-channel --add "https://nixos.org/channels/nixos-${NIXOS_VERSION}" nixos
	@sudo nix-channel --add "https://nixos.org/channels/nixos-unstable" nixos-unstable
	@sudo nix-channel --add "https://github.com/rycee/home-manager/archive/release-${NIXOS_VERSION}.tar.gz" home-manager
	@sudo nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs-unstable

update:
	@sudo nix-channel --update

switch:
	@sudo nixos-rebuild $(FLAGS) switch

install: channels update
	@sudo nixos-generate-config --root "$(PREFIX)" && sudo cp --update "$(NIXOS_PREFIX)/hardware-configuration.nix" "$$(pwd)/hosts/$(HOST)/hardware-configuration.nix"
	@echo "import \"$(DOTS)\" \"$(HOST)\" \"$${USER}\"" | sudo tee "${NIXOS_PREFIX}/configuration.nix"
	@sudo nixos-install --root "$(PREFIX)" $(FLAGS)
	@sudo cp -r "$(DOTS)" "$(PREFIX)/etc/dotfiles"
	@sudo nixos-enter --root "$(PREFIX)" -c chown $(USER):users $(DOTS)

clean:
	@sudo nix-collect-garbage -d

upgrade: update switch

rollback:
	@sudo nix-env --rollback

test:
	@nixos-rebuild $(FLAGS) test

