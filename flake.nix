{
  description = "foo-dogsquared's abomination of a NixOS configuration";

  nixConfig = {
    extra-substituters =
      "https://nix-community.cachix.org https://foo-dogsquared.cachix.org";
    extra-trusted-public-keys =
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E=";
    commit-lockfile-summary = "flake.lock: update inputs";
  };

  # Just take note we still set common flake inputs to our own version even if
  # we just use the modules and its overlays just so we don't download more of
  # them. Each flake update is like 100MB worth just from the multiple nixpkgs
  # branches at the following section, that's edging on the "too-much" scale
  # for my fragile internet bandwidth.
  inputs = {
    # I know NixOS can be stable but we're going cutting edge, baybee! While
    # `nixpkgs-unstable` branch could be faster delivering updates, it is
    # looser when it comes to stability for the entirety of this
    # configuration...
    nixpkgs.follows = "nixos-unstable";

    # ...except we allow other configurations to use other nixpkgs branch so
    # that may not matter anyways.
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # We're using these libraries for other functions.
    flake-utils.url = "github:numtide/flake-utils";

    # Managing home configurations.
    home-manager.follows = "home-manager-unstable";

    home-manager-stable.url = "github:nix-community/home-manager/release-24.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs";

    # Make a Neovim distro.
    nixvim.follows = "nixvim-unstable";

    nixvim-stable.url = "github:nix-community/nixvim/nixos-24.11";
    nixvim-stable.inputs.nixpkgs.follows = "nixos-stable";
    nixvim-stable.inputs.home-manager.follows = "home-manager-stable";

    nixvim-unstable.url = "github:nix-community/nixvim";
    nixvim-unstable.inputs.nixpkgs.follows = "nixos-unstable";
    nixvim-unstable.inputs.home-manager.follows = "home-manager-unstable";

    # Make a wrapper.
    wrapper-manager-fds.url =
      "github:foo-dogsquared/nix-module-wrapper-manager-fds";

    # This is what AUR strives to be.
    nur.url = "github:nix-community/NUR";

    # Configure those quirky hardware for you.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Generate your NixOS systems to various formats!
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Managing your secrets.
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS in Windows.
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # We're getting more unstable there should be a black hole at my home right
    # now. Also, we're seem to be collecting text editors like it is Pokemon.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";

    # Removing the manual partitioning part with a little boogie.
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Deploying stuff with Nix. This is becoming a monorepo for everything I
    # need and I'm liking it.
    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixpkgs";

    # Add a bunch of pre-compiled indices since mine are always crashing.
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Make a default.nix compatible stuff. Take note, we're giving this a
    # unique suffix since there are other flake inputs that uses the same flake
    # and we want our `default.nix` to refer to our version.
    flake-compat-fds.url =
      "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

    # Someone had the idea to make the flake outputs be configured as a Nix
    # module and I love them for it.
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      imports = [ ./modules/flake-parts ./configs/flake-parts ];
    };
}
