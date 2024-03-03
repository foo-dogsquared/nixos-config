# All of the extra module arguments to be passed as part of the home-manager
# environment.
{ pkgs, lib, options, ... }:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib =
    foodogsquaredLib.extend (final: prev: {
      home-manager = import ../../../lib/home-manager.nix { inherit pkgs lib; self = final; };
    } // lib.optionalAttrs (options?sops) {
      sops-nix = import ../../../lib/sops.nix { inherit pkgs lib; self = final; };
    });
}
