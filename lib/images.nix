# A set of functions intended for creating images. THis is meant to be imported
# for use in flake.nix and nowhere else.
{ inputs, lib }:

let
  inherit (inputs) nixpkgs home-manager nixos-generators;
in
{
  # A wrapper around the NixOS configuration function.
  mkHost = { system, extraModules ? [ ], extraArgs ? { }, nixpkgs-channel ? "nixpkgs" }:
    (lib.makeOverridable inputs."${nixpkgs-channel}".lib.nixosSystem) {
      # The system of the NixOS system.
      inherit system lib;
      specialArgs = extraArgs;
      modules =
        # Append with our custom NixOS modules from the modules folder.
        (import ../modules/nixos { inherit lib; isInternal = true; })

        # Our own modules.
        ++ extraModules;
    };

  # A wrapper around the home-manager configuration function.
  mkUser = { system, extraModules ? [ ], extraArgs ? { }, home-manager-channel ? "home-manager", nixpkgs-channel ? "nixpkgs" }:
    inputs."${home-manager-channel}".lib.homeManagerConfiguration {
      inherit lib;
      extraSpecialArgs = extraArgs;
      pkgs = import inputs."${nixpkgs-channel}" { inherit system; };
      modules =
        # Importing our custom home-manager modules.
        (import ../modules/home-manager { inherit lib; isInternal = true; })

        # Plus our own.
        ++ extraModules;
    };

  # A wrapper around the nixos-generators `nixosGenerate` function.
  mkImage = { system, pkgs ? null, extraModules ? [ ], extraArgs ? { }, format ? "iso" }:
    inputs.nixos-generators.nixosGenerate {
      inherit pkgs system format lib;
      specialArgs = extraArgs;
      modules =
        # Import all of the NixOS modules.
        (import ../modules/nixos { inherit lib; isInternal = true; })

        # Our own modules.
        ++ extraModules;
    };
}
