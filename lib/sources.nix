{ pkgs, lib, self }:

rec {
  /**
    A modified version of `lib.cleanSourceFilter` from nixpkgs that excludes
    version control system files.
  */
  cleanSourceFilter' =
    name: type:
    let
      baseName = baseNameOf (toString name);
    in
    !(
      # Filter out editor backup / swap files.
      lib.hasSuffix "~" baseName
      || builtins.match "^\\.sw[a-z]$" baseName != null
      || builtins.match "^\\..*\\.sw[a-z]$" baseName != null
      ||

      # Filter out generates files.
      lib.hasSuffix ".o" baseName
      || lib.hasSuffix ".so" baseName
      ||
      # Filter out nix-build result symlinks
      (type == "symlink" && lib.hasPrefix "result" baseName)
      ||
      # Filter out sockets and other types of files we can't have in the store.
      (type == "unknown")
    );

  cleanSource' = src:
    lib.sources.cleanSourceWith {
      inherit src;
      filter = cleanSourceFilter';
    };

  devFilenames = [
    "^node_modules$"
    "^.github$"
    "^.direnv$"
    ".envrc$"
  ];
}
