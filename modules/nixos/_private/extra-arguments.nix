# All of the extra module arguments to be passed as part of the holistic NixOS
# system.
{ pkgs, lib, options, ... }:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib =
    foodogsquaredLib.extend (final: prev: {
      nixos = import ../../../lib/env-specific/nixos.nix { inherit pkgs lib; self = final; };
    } // lib.optionalAttrs (options?sops) {
      sops-nix = import ../../../lib/env-specific/sops.nix { inherit pkgs lib; self = final; };
    });
}
