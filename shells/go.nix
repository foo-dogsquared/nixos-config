{ mkShell
, go
, gofumpt
, gopls
, callPackage
}:

let
  nodejsDevshell = callPackage ./nodejs.nix { };
in
mkShell {
  packages = [
    go
    gofumpt
    gopls
  ];

  inputsFrom = [ go nodejsDevshell ];
}
