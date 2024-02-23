{ pkgs, lib }:

{
  # TODO: Return a derivation containing all of the template output from the
  # given schemes.
  generateOutputFromSchemes = schemes: template:
    pkgs.runCommand "generate-templates" { } ''
    '';

  # TODO: Return a Nix object to generate a Tinted Theming color scheme from an
  # image.
  generateScheme = image: { };

  # A very naive implementation of checking if a Tinted Theming scheme is a
  # Base16 scheme.
  isBase16 = palette:
    let
      paletteNames = pkgs.lib.attrNames palette;
      schemeNames = builtins.map (number: "base${number}") (lib.hex.range 1 16);
    in
    (pkgs.lib.count (name: pkgs.lib.elem name schemeNames) paletteNames) == 16;

  # A very naive implementation of checking if a Tinted Theming scheme is a
  # Base24 scheme.
  isBase24 = palette:
    let
      paletteNames = pkgs.lib.attrNames palette;
      schemeNames = builtins.map (number: "base${number}") (pkgs.lib.hex.range 1 24);
    in
    (pkgs.lib.count (name: pkgs.lib.elem name schemeNames) paletteNames) == 24;
}
