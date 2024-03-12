# A module for specifically setting the nixpkgs instance with our own overlays.
{ lib, ... }:

{
  nixpkgs.overlays = lib.attrValues (import ../../../overlays);
}
