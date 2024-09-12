# The entrypoint for our custom library set.
#
# Take note, this is modularly included as part of the environment so we cannot
# have any functions or references that could make the evaluation go in an
# infinite recursion such as a function that generates a valid nixpkgs module.
# If you have to add those functions, you'll have to add them in configUtils.
{ pkgs }:

let
  inherit (pkgs) lib;
in
pkgs.lib.makeExtensible
(self:
  let
    callLib = file: import file { inherit pkgs lib self; };
  in {
    builders = callLib ./builders;
    trivial = callLib ./trivial.nix;
    data = callLib ./data.nix;
    math = callLib ./math.nix;
    fetchers = callLib ./fetchers;

    inherit (self.builders) makeXDGMimeAssociationList
      makeXDGPortalConfiguration makeXDGDesktopEntry;
    inherit (self.trivial) countAttrs filterAttrs';
    inherit (self.data) importYAML renderTeraTemplate renderMustacheTemplate;
    inherit (self.fetchers) fetchInternetArchive;
  } // lib.optionalAttrs (builtins ? fetchTree) {
    flake = callLib ./flake.nix;

    inherit (self.flake) importFlakeMetadata fetchTree fetchInput;
  })
