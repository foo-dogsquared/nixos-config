# All of the extra module arguments to be passed as part of NixVim module.
{ options, lib, ... }:

let
  foodogsquaredLib = import ../../../lib { inherit lib; };
in
{
  _module.args.foodogsquaredLib =
    foodogsquaredLib.extend (self:
      import ../../../lib/nixvim.nix { inherit lib; });
}
