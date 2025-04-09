{
  description = "foodogsquared's private repo";

  nixConfig = {
    extra-substituters =
      "https://nix-community.cachix.org https://foo-dogsquared.cachix.org";
    extra-trusted-public-keys =
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E=";
    commit-lockfile-summary = "flake.lock: update inputs";
  };

  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.follows = "home-manager-unstable";
    home-manager-stable.url = "github:nix-community/home-manager/release-24.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs";

    # My custom modules.
    fds-modules.url = "github:foo-dogsquared/nixos-config";

    # Make a default.nix compatible stuff. Take note, we're giving this a
    # unique suffix since there are other flake inputs that uses the same flake
    # and we want our `default.nix` to refer to our version.
    flake-compat-fds.url =
      "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      imports = [
        inputs.fds-modules.flakeModules.default
        inputs.fds-modules.flakeModules.baseSetupsConfig
        ./configs/flake-parts
      ];
    };
};
