{ inputs, inputOverride }:

let
  inputs' = inputs // inputOverride;

  flakeInputName = name: if name == "self" then "config" else name;
in ({ lib, ... }: let
  nixChannels =
    lib.mapAttrsToList (name: source: "${flakeInputName name}=${source}") inputs';
in {
  # I want to capture the usual flakes to its exact version so we're
  # making them available to our system. This will also prevent the
  # annoying downloads since it always get the latest revision.
  nix.registry = lib.mapAttrs' (name: flake:
    lib.nameValuePair (flakeInputName name) { inherit flake; }) inputs';

  nix.settings.nix-path = nixChannels;

  # It doesn't work on the traditional tools like nix-shell so ehhh...
  nix.nixPath = nixChannels;
})
