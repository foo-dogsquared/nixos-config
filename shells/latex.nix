# Ripperootskees for the space.
{ mkShell, texlive }:

mkShell {
  packages = [
    texlive.combined.scheme-full
  ];
}
