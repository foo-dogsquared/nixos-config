# A set of functions intended for creating images. THis is meant to be imported
# for use in flake.nix and nowhere else.
{ inputs, lib }:

let
  extendLib = self: super:
    import ./. { lib = super; }
    // import ./private.nix { lib = self; };
in
{
  # A thin wrapper around the NixOS configuration function.
  mkHost = { extraModules ? [ ], nixpkgs-channel ? "nixpkgs" }:
    let
      nixpkgs = inputs.${nixpkgs-channel};

      # Just to be sure, we'll use everything with the given nixpkgs' stdlib.
      lib' = nixpkgs.lib.extend extendLib;

      # A modified version of `nixosSystem` from nixpkgs flake. There is a
      # recent change at nixpkgs (at 039f73f134546e59ec6f1b56b4aff5b81d889f64)
      # that prevents setting our own custom functions so we'll have to
      # evaluate the NixOS system ourselves.
      nixosSystem = args: import "${nixpkgs}/nixos/lib/eval-config.nix" args;
    in
    (lib'.makeOverridable nixosSystem) {
      lib = lib';
      modules = extraModules;

      # Since we're setting it through nixpkgs.hostPlatform, we'll have to pass
      # this as null.
      system = null;
    };

  # A thin wrapper around the home-manager configuration function.
  mkHome = { pkgs, extraModules ? [ ], home-manager-channel ? "home-manager" }:
    inputs.${home-manager-channel}.lib.homeManagerConfiguration {
      inherit pkgs;
      lib = pkgs.lib.extend extendLib;
      modules = extraModules;
    };

  # A thin wrapper around the nixos-generators `nixosGenerate` function.
  mkImage = { pkgs ? null, extraModules ? [ ], format ? "iso" }:
    inputs.nixos-generators.nixosGenerate {
      inherit pkgs format;
      lib = pkgs.lib.extend extendLib;
      modules = extraModules;
    };

  # A function to modify the given table of declarative setups (i.e., hosts,
  # users) to have its own system attribute and its name.
  #
  # If the given setup only has one system, its name will stay the same.
  # Otherwise, it will be appended with the system as part of the name (e.g.,
  # `$NAME-$SYSTEM`).
  listImagesWithSystems = data:
    lib.foldlAttrs
      (acc: name: metadata:
        let
          name' = metadata.hostname or name;
        in
        if lib.length metadata.systems > 1 then
          acc // (lib.foldl
            (images: system: images // {
              "${name'}-${system}" = metadata // {
                _system = system;
                _name = name';
              };
            })
            { }
            metadata.systems)
        else
          acc // {
            "${name'}" = metadata // {
              _system = lib.head metadata.systems;
              _name = name';
            };
          })
      { }
      data;
}
