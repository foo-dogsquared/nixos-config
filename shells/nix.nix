# For usual Nix projects such as overlays, package repositories, and whatnot.
# Also, it's fun to have a file named `nix.nix`.
{ mkShell, lib, deadnix, jq, nil, nix-tree, nixfmt, nixpkgs-hammering, nurl
, rnix-hashes }:

mkShell {
  packages = [
    deadnix # Search for the dead.
    jq # It will use some JSON with its lockfile so better be ready to use this.
    nil # Language server.
    nix-tree # Suprisingly nice exploration tool for your packages in the store directory.
    nixfmt # Ideally, it would be nicer if the codebase has their preferred formatter but we'll go with the most common formatter(?).
    nixpkgs-hammering # Beat nixpkgs derivations up to shape.
    nurl # Nice way to catch up with some things.
    rnix-hashes # Quick utility for converting hashes.
  ];
}
