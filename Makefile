USER	:= foo-dogsquared
HOST	:= zilch
HOME	:= /home/$(USER)
DOTS	:= /etc/dotfiles

NIXOS_VERSION   := 20.09
NIXOS_PREFIX    := $(PREFIX)/etc/nixos
FLAGS           := -I "config=$$(pwd)/config" \
                   -I "modules=$$(pwd)/modules" \
                   -I "bin=$$(pwd)/bin" \
                   $(FLAGS)

# The channels will be used on certain modules like in `packages/default.nix` where it will be referred to install certain packages from the unstable channel.
channels:
	@sudo nix-channel --add "https://nixos.org/channels/nixos-unstable" nixos
	@sudo nix-channel --add "https://github.com/rycee/home-manager/archive/master.tar.gz" home-manager
	@sudo nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs

update:
	@sudo nix-channel --update

switch:
	@sudo nixos-rebuild $(FLAGS) switch

# 'boot' and 'switch' are somewhat the same except 'boot' takes care of setting the kernel so use this if you've changed the kernel settings.
boot:
	@sudo nixos-rebuild $(FLAGS) boot

# A little bootstrapping script.
install: channels update
	@sudo nixos-generate-config --root "$(PREFIX)"
	@echo "import \"$$(pwd)\" \"$(HOST)\" \"$${USER}\"" | sudo tee "${NIXOS_PREFIX}/configuration.nix"
	@sudo nixos-install --root "$(PREFIX)" $(FLAGS)
	@sudo cp -r "$(DOTS)" "$(PREFIX)/$(DOTS)"
	@echo "import \"$(DOTS)\" \"$(HOST)\" \"$${USER}\"" | sudo tee "${NIXOS_PREFIX}/configuration.nix"
	@sudo nixos-enter --root "$(PREFIX)" --command "chown $(USER):users $(DOTS) --recursive"
	@sudo nixos-enter --root "$(PREFIX)" --command "make -C $(DOTS) channels"
	@echo "Set password for $(USER)" && sudo nixos-enter --root "$(PREFIX)" --command "passwd $(USER)"

clean:
	@nix-collect-garbage -d

upgrade: update switch

rollback:
	@sudo nixos-rebuild switch $(FLAGS) --rollback

test:
	@nixos-rebuild $(FLAGS) test

