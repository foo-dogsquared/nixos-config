# The wrapper-manager library set. It should only require a nixpkgs instance to
# make initializing this set easier. This what makes it possible to be used as
# part of the module environments and as a standalone library.
#
# Since this library set is typically modularly set in nixpkgs module
# environments, we'll have to make sure it doesn't contain any functions that
# should return a nixpkgs module or anything of the sort. Basically, this
# should remain as a utility function that is usable outside of the nixpkgs
# module.
{ pkgs }:

pkgs.lib.makeExtensible
  (self:
  let
    callLibs = file: import file { inherit (pkgs) lib; inherit pkgs self; };
  in
  {
    env = import ./env.nix;
    utils = callLibs ./utils.nix;

    inherit (self.env) build eval;
    inherit (self.utils) getBin getLibexec;
  })

