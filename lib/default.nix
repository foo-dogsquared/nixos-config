# The entrypoint for our custom library set.
{ pkgs }:

pkgs.lib.makeExtensible
(self:
  let
    inherit (pkgs) lib;
    callLib = file: import file { inherit pkgs lib self; };
  in {
    trivial = callLib ./trivial.nix;

    inherit (self.trivial) countAttrs getConfig getUser;
  })
