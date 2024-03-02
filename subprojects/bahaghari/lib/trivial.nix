{ pkgs, lib }:

rec {
  inherit (pkgs.lib.generators) toYAML;

  /* Read YAML files into a Nix expression similar to lib.importJSON and
     lib.importTOML from nixpkgs standard library. Unlike both of them, this
     unfortunately relies on an import-from-derivation (IFD) so it isn't exactly
     perfect but it is very close.

     This relies on yaml2json which uses the following YAML library which you
     can view the following link for more details on YAML compatibility.

     https://pkg.go.dev/gopkg.in/yaml.v3#readme-compatibility

     Type: importYAML :: Path -> any

     Example:
       importYAML ./simple.yml
  */
  importYAML = path:
    let
      dataDrv = pkgs.runCommand "convert-yaml-to-json" { } ''
        ${pkgs.lib.getExe' pkgs.yaml2json "yaml2json"} < "${path}" > "$out"
      '';
    in
    pkgs.lib.importJSON dataDrv;

  /* Convert a given decimal number to a specified base digit with the set of
     glyphs for each digit as returned from lib.toBaseDigits.

     Type: toBaseDigitWithGlyphs :: Int -> Int -> Attrs -> String

     Example:
       toBaseDigitWithGlyphs 24 267 {
          "0" = "0";
          "1" = "1";
          "2" = "2";
          # ...
          "22" = "O";
          "23" = "P";
        }
      =>
  */
  toBaseDigitsWithGlyphs = base: i: glyphs:
    let
      baseDigits = pkgs.lib.toBaseDigits base i;
      toBaseDigits = d: glyphs.${builtins.toString d};
    in
    pkgs.lib.concatMapStrings toBaseDigits baseDigits;

  /* Generates a glyph set usable for `toBaseDigitsWithGlyphs`. Take note the
     given list is assumed to be sorted and the generated glyph set starts at
     `0` up to (`listLength - 1`).

     Type: generateGlyphSet :: [ String ] -> Attrs

     Example:
       generateGlyphSet [ "0" "1" "2" "3" "4" "5" "6" "7" "8 "9" "A" "B" "C" "D" "E" "F" ]
       => {
         "0" = "0";
         "1" = "1";
         # ...
         "14" = "E";
         "15" = "F";
       }
  */
  generateGlyphSet = glyphsList:
    let
      glyphsList' =
        pkgs.lib.lists.imap0
          (i: glyph: pkgs.lib.nameValuePair (builtins.toString i) glyph)
          glyphsList;
    in
    pkgs.lib.listToAttrs glyphsList';

  /* Generates a conversion table for a sorted list of glyphs to its decimal
     number. Suitable for creating your own conversion function. Accepts the
     same argument as `generateGlyphSet`.

     Type: generateConversionTable :: [ String ] -> Attrs

     Example:
       generateGlyphSet [ "0" "1" "2" "3" "4" "5" "6" "7" "8 "9" "A" "B" "C" "D" "E" "F" ]
       => {
         "0" = 0;
         "1" = 1;
         # ...
         "E" = 14;
         "F" = 15;
       }
  */
  generateConversionTable = glyphsList:
    let
      glyphsList' =
        pkgs.lib.lists.imap0
          (i: glyph: pkgs.lib.nameValuePair glyph i)
          glyphsList;
    in
    pkgs.lib.listToAttrs glyphsList';

  /* A factory function for generating an attribute set containing a glyph
     set, a conversion table, and a conversion function to and from decimal.
     Accepts the same list as `generateGlyphSet` and
     `generateConversionTable` where it assumes it is sorted and
     zero-indexed.

     Type: generateBaseDigitType :: [ String ] -> Attrs

     Example:
      generateBaseDigitType [ "0" "1" ]
      => {
        base = 2;
        glyphSet = { "0" = "0"; "1" = "1"; };
        conversionTable = { "0" = 0; "1" = 1; };
        fromDec = <function>;
        toDec = <function>;
      }
  */
  generateBaseDigitType = glyphsList: rec {
    base = pkgs.lib.length glyphsList;
    glyphSet = generateGlyphSet glyphsList;
    conversionTable = generateConversionTable glyphsList;

    # Unfortunately, these functions cannot handle negative numbers unless we
    # implement something like Two's complement. For now, we're not worrying
    # about that since most of the use cases here will be mostly for color
    # generation that typically uses hexadecimal (RGB). Plus I don't want to
    # open a can of worms about implementing this with stringy types.
    fromDec = decimal:
      let
        digits = pkgs.lib.toBaseDigits base decimal;
      in
      pkgs.lib.concatMapStrings (d: glyphSet.${builtins.toString d}) digits;

    toDec = digit:
      let
        chars = pkgs.lib.stringToCharacters digit;
        maxDigits = (pkgs.lib.length chars) - 1;
        convertDigitToDec =
          pkgs.lib.lists.imap0 (i: v: conversionTable.${v} * (lib.math.pow base (maxDigits - i))) chars;
      in
      pkgs.lib.foldl (sum: v: sum + v) 0 convertDigitToDec;
  };

  /* Given a range of two numbers, ensure the value is only returned within the
     range.

     Type: clamp :: Number -> Number -> Number -> Number

     Example:
       clamp 0 255 654
       => 255

       clamp (-100) 100 (-234)
       => -100
  */
  clamp = min: max: value:
    pkgs.lib.min max (pkgs.lib.max min value);
}
