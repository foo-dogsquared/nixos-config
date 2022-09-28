{ mkShell
, go
, gofumpt
, gopls
}:

mkShell {
  packages = [
    go
    gofumpt
    gopls
  ];
}
