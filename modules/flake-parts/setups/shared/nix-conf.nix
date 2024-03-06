{ inputs }:

{ config, lib, ... }:

let
  inputs' = inputs // {
    nixpkgs = inputs.${config.nixpkgsBranch};
    home-manager = inputs.${config.homeManagerBranch};
  };
in
{
  config.modules = [(
    { lib, ... }: {
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
          inputs';

      nix.settings.nix-path =
        (lib.mapAttrsToList
          (name: source:
            let
              name' = if (name == "self") then "config" else name;
            in
            "${name'}=${source}")
          inputs'
        ++ [
          "/nix/var/nix/profiles/per-user/root/channels"
        ]);
      }
  )];
}
