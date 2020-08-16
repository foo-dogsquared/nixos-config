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

channels:
	@sudo nix-channel --add "https://nixos.org/channels/nixos-unstable" nixos
	@sudo nix-channel --add "https://github.com/rycee/home-manager/archive/master.tar.gz" home-manager

update:
	@sudo nix-channel --update

switch:
	@sudo nixos-rebuild $(FLAGS) switch

install: channels update
	@echo "import "$(DOTS)" \"$${HOST:-$$(hostname)}\" \"$${USER}\"" | sudo tee "${NIXOS_PREFIX}/configuration.nix"
	@sudo nixos-install --root "$(PREFIX)" $(FLAGS)
	@sudo rm -r "$(PREFIX)/etc/dotfiles" && sudo cp -r "$(DOTS)" "$(PREFIX)/etc/dotfiles"
	@sudo nixos-enter --root "$(PREFIX)" -c chown $(USER):users $(DOTS)

upgrade: update switch

