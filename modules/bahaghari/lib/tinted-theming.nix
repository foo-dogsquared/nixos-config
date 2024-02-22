{ pkgs, lib }:

{
  # A very naive implementation of checking if a Tinted Theming scheme is a
  # Base16 scheme.
  isBase16 = palette:
    let
      paletteNames = lib.attrNames palette;
      schemeNames = builtins.map (number: "base${number}") [
        "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "0A"
        "0B" "0C" "0D" "0E" "0F"
      ];
    in
    (lib.count (name: lib.elem name schemeNames) paletteNames) == 16;

  # A very naive implementation of checking if a Tinted Theming scheme is a
  # Base24 scheme.
  isBase24 = palette:
    let
      paletteNames = lib.attrNames palette;
      schemeNames = builtins.map (number: "base${number}") [
        "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "0A"
        "0B" "0C" "0D" "0E" "0F" "10" "11" "12" "13" "14" "15"
        "16" "17"
      ];
    in
    (lib.count (name: lib.elem name schemeNames) paletteNames) == 24;
}
