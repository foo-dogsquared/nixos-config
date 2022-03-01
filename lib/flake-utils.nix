# A list of utilities specifically in my flake output. Take note it needs
# `lib/default.nix` for it to work.
{ lib, inputs }:

let
  # Default system for our host configuration.
  sys = "x86_64-linux";
in rec {
  /* Create a NixOS system through a given host folder.
     It will automate some of the things such as making the last component
     of the path as the hostname.

     This is a wrapper for `nixpkgs.lib.nixosSystem`.

     Signature:
       path -> attrset -> NixOS configuration
     Where:
       - `path` is a path to a Nix file for the host; the basename of the file
         is also used as the hostname
       - `attrset` is the attribute set to be included in the host configuration
     Returns:
       An attribute set from the `lib.nixosSystem` from `nixpkgs` flake.

     Example:
       mkHost ./hosts/june {}
       => { ... } # NixOS configuration attrset
  */
  mkHost = file:
    attrs@{ system ? sys, specialArgs ? { inherit lib system inputs; }, ... }:
    (lib.makeOverridable inputs.nixpkgs.lib.nixosSystem) {
      # The system of the NixOS system.
      inherit system specialArgs;

      # We also set the following in order for priority.
      # Later modules will override previously imported modules.
      modules = [
        # Set the hostname.
        {
          networking.hostName = builtins.baseNameOf file;
        }

        # Put the given attribute set (except for the system).
        (lib.filterAttrs (n: v: !lib.elem n [ "system" "specialArgs" ]) attrs)

        # The entry point of the module.
        file
      ]
      # Append with our custom NixOS modules from the modules folder.
        ++ (lib.modulesToList (lib.filesToAttr ../modules/nixos));
    };

  /* Create a home-manager configuration for use in flakes.

     This is a wrapper for `home-manager.lib.homeManagerConfiguration`.

     Signature:
       file -> attrset -> homeManagerConfiguration
     Where:
       - `file` is the entry point to the home-manager configuration.
       - `attrset` is the additional attribute set to be insert as one of the
         imported modules minus the attributes used for
         `home-manager.lib.homeManagerConfiguration`.
     Returns:
       A home-manager configuration to be exported in flakes.

     Example:
       mkUser ./users/foo-dogsquared {}
       => { ... } # A home-manager configuration set.
  */
  mkUser = file:
    attrs@{ username ? (builtins.baseNameOf file), system ? sys
    , extraModules ? [ ], extraSpecialArgs ? { inherit lib system; }, ... }:
    let
      hmConfigFunctionArgs = builtins.attrNames (builtins.functionArgs
        inputs.home-manager.lib.homeManagerConfiguration);
      hmModules = lib.map (path: import path)
        (lib.modulesToList (lib.filesToAttrRec ../modules/home-manager));
    in inputs.home-manager.lib.homeManagerConfiguration {
      inherit system username extraSpecialArgs;
      configuration = import file;
      homeDirectory = "/home/${username}";
      extraModules = hmModules ++ extraModules
        ++ [ (lib.filterAttrs (n: _: !lib.elem n hmConfigFunctionArgs) attrs) ];
    };
}
