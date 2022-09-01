{ mkShell
, lib
, guile
, guile-hall
}:

let
  guileVersion = lib.versions.majorMinor guile.version;
in
mkShell {
  inherit guileVersion;
  packages = [
    guile
    guile-hall
  ];

  # This is already properly exported through setup hooks but to make
  # intentions clearer.
  shellHook = ''
    export GUILE_LOAD_PATH GUILE_LOAD_COMPILED_PATH

    if test $guileVersion == "3.0"; then
      export GUILE_EXTENSIONS_PATH
    fi
  '';
}
