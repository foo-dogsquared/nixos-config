# The NixOS library set.
{ lib }:

import ../default.nix { inherit lib; }
// import ../nixos.nix { inherit lib; }
// { sops-nix = import ../sops.nix { inherit lib; }; }
