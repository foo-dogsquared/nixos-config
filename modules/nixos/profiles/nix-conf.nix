{ config, lib, pkgs, ... }: {
  # Set the package for generating the configuration.
  nix.package = lib.mkDefault pkgs.nixStable;

  # Set the configurations for the package manager.
  nix.settings = {
    # Set several binary caches.
    substituters = [
      "https://nix-community.cachix.org"
      "https://foo-dogsquared.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E="
    ];

    # Sane config for the package manager.
    # TODO: Remove this after nix-command and flakes has been considered
    # stable.
    #
    # Since we're using flakes to make this possible, we need it. Plus, the
    # UX of Nix CLI is becoming closer to Guix's which is a nice bonus.
    experimental-features =
      [ "nix-command" "flakes" ]
      ++ lib.optionals (lib.versionOlder config.nix.package.version "2.22.0") [ "repl-flake" ];
    auto-optimise-store = lib.mkDefault true;

    # We don't want to download every time we invoke Nix, seriously. Thanks.
    flake-registry = "";
  };

  # Stallman-senpai will be disappointed.
  nixpkgs.config.allowUnfree = true;
}
