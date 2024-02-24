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

  /* A very naive implementation of checking whether the given palette is a
     valid Base16 palette. It simply checks if `base00` to `base0F` is present.

     Type: isBase16 :: Attrs -> Bool

     Example:
      isBase16 (bahaghariLib.importYAML ./base16.yml).palette
      => true

      isBase16 (bahaghariLib.importYAML ./base16-scheme-with-missing-base0F.yml).palette
      => false
  */
  isBase16 = isBaseX 16;

  /* Similar to `isBase16` but for Base24 schemes. It considers the scheme as
     valid if `base00` to `base17` from the palette are present.

     Type: isBase24 :: Attrs -> Bool

     Example:
      isBase24 (bahaghariLib.importYAML ./base24.yml).palette
      => true

      isBase24 (bahaghariLib.importYAML ./base24-scheme-with-missing-base0F.yml).palette
      => false
  */
  isBase24 = isBaseX 24;
}
