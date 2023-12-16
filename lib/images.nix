# A set of functions intended for creating images. THis is meant to be imported
# for use in flake.nix and nowhere else.
{ inputs, lib }:

let
  extendLib = self: super:
    import ./. { lib = super; }
    // import ./private.nix { lib = self; };
in
{
  # A wrapper around the NixOS configuration function.
  mkHost = { extraModules ? [ ], nixpkgs-channel ? "nixpkgs" }:
    let lib' = inputs.${nixpkgs-channel}.lib.extend extendLib; in
    (lib'.makeOverridable lib'.nixosSystem) {
      modules = extraModules;
    };

  # A wrapper around the home-manager configuration function.
  mkHome = { pkgs, extraModules ? [ ], home-manager-channel ? "home-manager" }:
    inputs.${home-manager-channel}.lib.homeManagerConfiguration {
      inherit pkgs;
      lib = pkgs.lib.extend extendLib;
      modules = extraModules;
    };

  # A wrapper around the nixos-generators `nixosGenerate` function.
  mkImage = { pkgs ? null, extraModules ? [ ], format ? "iso" }:
    inputs.nixos-generators.nixosGenerate {
      inherit pkgs format;
      lib = pkgs.lib.extend extendLib;
      modules = extraModules;
    };

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
