{ inputs }:

{ config, lib, ... }:

let
  inputs' = inputs // {
    nixpkgs = inputs.${config.nixpkgs.branch};
    home-manager = inputs.${config.homeManagerBranch};
  };

  flakeInputName = name:
    if name == "self" then "config" else name;

  nixChannels =
    lib.mapAttrsToList
      (name: source: "${flakeInputName name}=${source}")
      inputs'
    ++ [
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
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
            lib.nameValuePair (flakeInputName name) { inherit flake; })
          inputs';

      nix.settings.nix-path = nixChannels;

      # It doesn't work on the traditional tools like nix-shell so ehhh...
      nix.nixPath = nixChannels;
    }
  )];
}
