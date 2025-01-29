{ pkgs, lib, self }:

rec {
  inherit (pkgs.lib.generators) toYAML;

  /* *
     Read YAML files into a Nix expression similar to lib.importJSON and
     lib.importTOML from nixpkgs standard library. Unlike both of them, this
     unfortunately relies on an import-from-derivation (IFD) so it isn't exactly
     perfect but it is very close.

     This relies on yaml2json which uses the following YAML library which you
     can view the following link for more details on YAML compatibility.

     https://pkg.go.dev/gopkg.in/yaml.v3#readme-compatibility

     # Arguments

     file
     : The filepath of the YAML file.

     # Type

     ```
     importYAML :: Path -> any
     ```

     # Example

     ```
     importYAML ./simple.yml
     =>
     {
       hello = "there";
       how-are-you-doing = "I'm fine. Thank you for asking.";
     }
     ```
  */
  importYAML = path:
    let
      dataDrv = pkgs.runCommand "convert-yaml-to-json" { } ''
        ${lib.getExe' pkgs.yaml2json "yaml2json"} < "${path}" > "$out"
      '';
    in lib.importJSON dataDrv;

  /* *
     Convert a given decimal number to a specified base digit with the set of
     glyphs for each digit as returned from lib.toBaseDigits.

     # Arguments

     base
     : The base index.

     glyphs
     : An attribute set of decimal values and their glyphs.

     i
     : The actual integer to be converted.

     # Type

     ```
     toBaseDigitWithGlyphs :: Int -> Int -> Attrs -> String
     ```

     # Example

     ```
     toBaseDigitWithGlyphs 24 267 {
        "0" = "0";
        "1" = "1";
        "2" = "2";
        # ...
        "22" = "M";
        "23" = "N";
      }
     =>
     "12H"

     toBaseDigitWithGlyphs
     ```
  */
  toBaseDigitsWithGlyphs = base: glyphs: i:
    let
      baseDigits = lib.toBaseDigits base i;
      toBaseDigits = d: glyphs.${builtins.toString d};
    in lib.concatMapStrings toBaseDigits baseDigits;

  /* *
     Generates a glyph set usable for `toBaseDigitsWithGlyphs`. Take note the
     given list is assumed to be sorted and the generated glyph set starts at
     `0` up to (`listLength - 1`).

     # Arguments

     glyphsList
     : A sorted list of glyphs.

     # Type

     ```
     generateGlyphSet :: [ String ] -> Attrs
     ```

     # Example

     ```
     generateGlyphSet [ "0" "1" "2" "3" "4" "5" "6" "7" "8 "9" "A" "B" "C" "D" "E" "F" ]
     =>
     {
       "0" = "0";
       "1" = "1";
       # ...
       "14" = "E";
       "15" = "F";
     }
     ```
  */
  generateGlyphSet = glyphsList:
    let
      glyphsList' = lib.lists.imap0
        (i: glyph: lib.nameValuePair (builtins.toString i) glyph) glyphsList;
    in lib.listToAttrs glyphsList';

  /* *
     Generates a conversion table for a sorted list of glyphs to its decimal
     number. Suitable for creating your own conversion function. Accepts the
     same argument as `generateGlyphSet`.

     # Arguments

     glyphsList
     : A sorted list of glyphs.

     # Type

     ```
     generateConversionTable :: [ String ] -> Attrs
     ```

     # Example

     ```
     generateConversionTable [ "0" "1" "2" "3" "4" "5" "6" "7" "8 "9" "A" "B" "C" "D" "E" "F" ]
     =>
     {
       "0" = 0;
       "1" = 1;
       # ...
       "E" = 14;
       "F" = 15;
     }
     ```
  */
  generateConversionTable = glyphsList:
    let
      glyphsList' =
        lib.lists.imap0 (i: glyph: lib.nameValuePair glyph i) glyphsList;
    in lib.listToAttrs glyphsList';

  /* *
     A factory function for generating an attribute set containing a glyph
     set, a conversion table, and a conversion function to and from decimal.
     Accepts the same list as `generateGlyphSet` and
     `generateConversionTable` where it assumes it is sorted and
     zero-indexed.

     # Arguments

     glyphsList
     : A sorted list of glyphs.

     # Type

     ```
     generateBaseDigitType :: [ String ] -> Attrs
     ```

     # Example

     ```
     generateBaseDigitType [ "0" "1" ]
     =>
     {
       base = 2;
       glyphSet = { "0" = "0"; "1" = "1"; };
       conversionTable = { "0" = 0; "1" = 1; };
       fromDec = <function>;
       toDec = <function>;
     }
     ```
  */
  generateBaseDigitType = glyphsList: rec {
    base = lib.length glyphsList;
    glyphSet = generateGlyphSet glyphsList;
    conversionTable = generateConversionTable glyphsList;

    # Unfortunately, these functions cannot handle negative numbers unless we
    # implement something like Two's complement. For now, we're not worrying
    # about that since most of the use cases here will be mostly for color
    # generation that typically uses hexadecimal (RGB). Plus I don't want to
    # open a can of worms about implementing this with stringy types.
    fromDec = decimal:
      let digits = lib.toBaseDigits base decimal;
      in lib.concatMapStrings (d: glyphSet.${builtins.toString d}) digits;

    toDec = digit:
      let
        chars = lib.stringToCharacters digit;
        maxDigits = (lib.length chars) - 1;
        convertDigitToDec = lib.lists.imap0
          (i: v: conversionTable.${v} * (self.math.pow base (maxDigits - i)))
          chars;
      in lib.foldl (sum: v: sum + v) 0 convertDigitToDec;
  };

  /* *
     Given a range of two numbers, ensure the value is only returned within the
     range.

     # Arguments

     min
     : Minimum number of the range.

     max
     : Maximum number of the range.

     value
     : Number to be used for the function.

     # Type

     ```
     clamp :: Number -> Number -> Number -> Number
     ```

     # Example

     ```
     clamp 0 255 654
     =>
     255

     clamp (-100) 100 (-234)
     =>
     -100

     clamp (-100) 100 54
     =>
     54
     ```
  */
  clamp = min: max: value: lib.min max (lib.max min value);

  /* *
     Given a value, check if it's a number type.

     # Arguments

     value
     : Numerical value.

     # Type

     ```
     isNumber :: Number -> bool
     ```

     # Example:

     ```
     isNumber 3.0
     =>
     true

     isNumber 653
     =>
     true

     isNumber true
     =>
     false
     ```
  */
  isNumber = v: lib.isInt v || lib.isFloat v;

  /* *
     Given a Nix number, force it to be a floating value.

     # Arguments

     value
     : The numerical value.

     # Type

     ```
     toFloat :: Number -> Float
     ```

     # Example

     ```
     toFloat 5
     =>
     5.0

     toFloat 59.0
     =>
     59.0
     ```
  */
  toFloat = x: 1.0 * x;

  /* *
     Given an initial range of integers, scale the given number with its own
     set of range.

     # Arguments

     rangeSet
     : An attribute set containing the following attributes: `inMin` and `inMax`
     for specifying the input's expected range and `outMin` and `outMax` for the
     output's.

     value
     : The numerical value.

     # Type

     ```
     scale :: Attrs -> Number -> Number
     ```

     # Example

     ```
     scale { inMin = 0; inMax = 15; outMin = 0; outMax = 255; } 4
     =>
     68

     scale { inMin = 0; inMax = 15; outMin = 0; outMax = 255; } (-4)
     =>
     -68

     scale { inMin = 0; inMax = 15; outMin = 0; outMax = 255; } 15
     =>
     255
     ```
  */
  scale = { inMin, inMax, outMin, outMax }:
    v:
    ((v - inMin) * (outMax - outMin)) / ((inMax - inMin) + outMin);

  /* *
     Returns a null value if the condition fails. Otherwise, returns the given
     value `as`.

     # Arguments

     cond
     : Condition that should evaluate as a boolean.

     as
     : Value to be returned if condition returns true.

     # Type

     ```
     optionalNull :: Bool -> Any -> Any
     ```

     # Example

     ```
     optionalNull true "HELLO"
     => "HELLO"

     optionalNull (null != null) "HELLO"
     => null
     ```
  */
  optionalNull = cond: as: if cond then as else null;
}
