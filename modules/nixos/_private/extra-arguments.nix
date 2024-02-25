# All of the extra module arguments to be passed as part of the holistic NixOS
# system.
{ options, lib, pkgs, ... }:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib =
    foodogsquaredLib.extend (final: prev:
      import ../../../lib/nixos.nix { inherit pkgs; lib = prev; }
      // lib.optionalAttrs (options?sops) {
        sops-nix = import ../../../lib/sops.nix { inherit pkgs; lib = prev; };
      });
}
