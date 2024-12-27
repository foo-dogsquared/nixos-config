# A standalone version of the dconf profile generation build step based from
# the nixpkgs' NixOS dconf module.
{ lib, runCommand, dconf }:

{ dir, name ? baseNameOf dir, keyfiles, profile }@args:

runCommand "dconf-${name}" {
  nativeBuildInputs = [ (lib.getBin dconf) ];
} "dconf compile $out ${dir}"
