{ mkShell, lib, nixfmt, rnix-lsp }:

mkShell {
  packages = [
    nixfmt
    rnix-lsp
  ];
}
