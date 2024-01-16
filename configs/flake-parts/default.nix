{ inputs, lib, ... }: {
  imports = [
    ./dev.nix
    ./packages.nix
    ./templates.nix

    # The environment configurations.
    ./home-manager.nix
    ./nixos.nix
  ];

  _module.args = {
    # This will be shared among NixOS and home-manager configurations.
    defaultNixConf = { config, lib, pkgs, ... }: {
      # I want to capture the usual flakes to its exact version so we're
      # making them available to our system. This will also prevent the
      # annoying downloads since it always get the latest revision.
      nix.registry =
        lib.mapAttrs'
          (name: flake:
            let
              name' = if (name == "self") then "config" else name;
            in
            lib.nameValuePair name' { inherit flake; })
          inputs;

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
        experimental-features = [ "nix-command" "flakes" "repl-flake" ];
        auto-optimise-store = lib.mkDefault true;
      };

      # Stallman-senpai will be disappointed.
      nixpkgs.config.allowUnfree = true;

      # Extend nixpkgs with our overlays except for the NixOS-focused modules
      # here.
      nixpkgs.overlays = lib.attrValues inputs.self.overlays;
    };

    defaultOverlays = lib.attrValues inputs.self.overlays;
    defaultExtraArgs = {
      inherit (inputs) nix-colors;
    };
  };

  perSystem = { lib, system, ... }: {
    _module.args = {
      # nixpkgs for this module should be used as less as possible especially
      # for building NixOS and home-manager systems.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = lib.attrValues inputs.self.overlays ++ [
          inputs.nur.overlay
        ];
      };
    };
  };
}
