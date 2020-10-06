USER	:= foo-dogsquared
HOST	:= zilch
HOME	:= /home/$(USER)
DOTS	:= /etc/dotfiles

NIXOS_VERSION	:= 20.09
NIXOS_PREFIX	:= $(PREFIX)/etc/nixos
FLAGS		:= -I "config=$$(pwd)/config" \
                   -I "modules=$$(pwd)/modules" \
                   -I "bin=$$(pwd)/bin" \
                   $(FLAGS)

config:	$(NIXOS_PREFIX)/configuration.nix
home:	$(HOME)/dotfiles

# The channels will be used on certain modules like in `packages/default.nix` where it will be referred to install certain packages from the unstable channel.
channels:
	@sudo nix-channel --add "https://nixos.org/channels/nixos-unstable" nixos
	@sudo nix-channel --add "https://github.com/rycee/home-manager/archive/master.tar.gz" home-manager
	@sudo nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs-unstable

update:
	@sudo nix-channel --update

switch:
	@sudo nixos-rebuild $(FLAGS) switch

# 'boot' and 'switch' are somewhat the same except 'boot' takes care of setting the kernel so use this if you've changed the kernel settings.
boot:
	@sudo nixos-rebuild $(FLAGS) boot

install: channels update
	@sudo nixos-generate-config --root "$(PREFIX)"
	@echo "import \"$(DOTS)\" \"$(HOST)\" \"$${USER}\"" | sudo tee "${NIXOS_PREFIX}/configuration.nix"
	@sudo nixos-install --root "$(PREFIX)" $(FLAGS)
	@sudo cp -r "$(DOTS)" "$(PREFIX)/etc/dotfiles"
	@sudo nixos-enter --root "$(PREFIX)" --command "chown $(USER):users $(DOTS) --recursive"
	@sudo nixos-enter --root "$(PREFIX)" --command "make -C $(DOTS) channels"
	@echo "Set password for $(USER)" && sudo nixos-enter --root "$(PREFIX)" --command "passwd $(USER)"

clean:
	@nix-collect-garbage -d

upgrade: update switch

rollback:
	@sudo nix-env --rollback

test:
	@nixos-rebuild $(FLAGS) test

