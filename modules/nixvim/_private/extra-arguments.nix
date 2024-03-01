# All of the extra module arguments to be passed as part of NixVim module.
{ options, config, lib, pkgs, ... }:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib =
    foodogsquaredLib.extend (final: prev: {
      nixvim = import ../../../lib/nixvim.nix { inherit pkgs; lib = prev; };
    });
}
