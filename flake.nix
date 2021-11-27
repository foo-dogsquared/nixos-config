{
  description = "foo-dogsquared's NixOS config as a flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    digga.url = "github:divnix/digga";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      libExtended = nixpkgs.lib.extend
        (final: prev: (import ./lib { inherit inputs; lib = final; }));

      hostDefaultConfig = {
        # Stallman-senpai will be disappointed.
        nixpkgs.config.allowUnfree = true;
      
        # We live in a Unicode world and dominantly English in technical fields so we'll
        # have to go with it.
        i18n.defaultLocale = "en_US.UTF-8";
      
        # Sane config for the package manager.
        nix.gc = {
          automatic = true;
          dates = "monthly";
          options = "--delete-older-than 2w";
        };
      
        # TODO: Remove this after nix-command and flakes has been considered stable.
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
    in {
      # Exposes only my library with the custom functions to make it easier to include in other flakes.
      lib = import ./lib { inherit inputs; lib = nixpkgs.lib; };

      # A list of NixOS configurations from the `./hosts` folder.
      # It also has some sensible default configurations.
      nixosConfigurations =
        libExtended.mapAttrs (host: path: libExtended.mkHost path hostDefaultConfig) (libExtended.filesToAttr ./hosts); 

      # We're going to make our custom modules available for our flake. Whether
      # or not this is a good thing is debatable, I just want to test it.
      nixosModules =
        libExtended.mapAttrs (_: path: import path) (libExtended.filesToAttr ./modules);
    };
}
