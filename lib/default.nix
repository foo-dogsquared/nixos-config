# The entrypoint for our custom library set. Take note, this is modularly
# included as part of the environment so we cannot have any functions or
# references that could make the evaluation go in an infinite recursion such as
# a function that generates a valid nixpkgs module.
{ pkgs }:

pkgs.lib.makeExtensible
(self:
  let
    inherit (pkgs) lib;
    callLib = file: import file { inherit pkgs lib self; };
  in {
    trivial = callLib ./trivial.nix;
    data = callLib ./data.nix;

    inherit (self.trivial) countAttrs getConfig getUser;
    inherit (self.data) importYAML renderTeraTemplate;
  })
