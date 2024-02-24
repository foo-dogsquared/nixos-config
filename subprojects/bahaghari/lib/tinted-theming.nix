{ pkgs, lib }:

let
  isBaseX = i: palette:
    let
      paletteNames = pkgs.lib.attrNames palette;
      maxDigitLength = pkgs.lib.lists.length (pkgs.lib.toBaseDigits 10 i);
      mkBaseAttr = hex: "base${lib.hex.pad maxDigitLength hex}";
      schemeNames = builtins.map mkBaseAttr (lib.hex.range 0 (i - 1));
    in
      (pkgs.lib.count (name: pkgs.lib.elem name schemeNames) paletteNames) == i;
in
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
  isBase16 = isBaseX 16;

  # Same but with Base24 scheme.
  isBase24 = isBaseX 24;
}
