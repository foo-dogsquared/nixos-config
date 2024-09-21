# The most antiquated colorspace like ever. For this implementation, we will be
# looking after the RGB specification (especially the hexadecimal notation) as
# specified from W3 CSS Color Module Level 4
# (https://www.w3.org/TR/css-color-4) since it is the most common one.
{ pkgs, lib, self }:

rec {
  # A bunch of metadata for this implementation. Might be useful if you want to
  # create functions from this subset.
  valueMin = 0.0;
  valueMax = 255.0;

  /* Generates an RGB colorspace object. The point is to provide some
     typechecking if the values passed are correct.

     Type: RGB :: Attrs -> Attrs

     Example:
       RGB { r = 242.0; g = 12; b = 23; }
       => {
         # The individual red, green, and blue components.
       }
  */
  RGB = { r, g, b, ... }@color:
    assert lib.assertMsg (isRgb color)
      "bahaghariLib.colors.rgb.RGB: Given object has invalid values (only 0-255 are allowed)";
    lib.optionalAttrs (color ? a) { inherit (color) a; } // {
      inherit r g b;
    };

  /* Returns a boolean to check if it's a valid RGB Nix object or not.

     Type: isRgb :: Attrs -> Bool

     Example:
       isRgb { r = 34; g = 43; b = 555; }
       # `b` is more than 255.0 so it's a false
       => false

       isRgb { r = 123; g = null; b = 43; }
       # `g` is not a number so it's'a false again
       => false

       isRgb { r = 123; g = 123; b = 123; }
       => true
  */
  isRgb = { r, g, b, ... }@color:
    let
      isWithinRGBRange = v: self.math.isWithinRange valueMin valueMax v;
      isValidRGB = v: self.isNumber v && isWithinRGBRange v;
      colors = [ r g b ] ++ lib.optionals (color ? a) [ color.a ];
    in lib.lists.all (v: isValidRGB v) colors;

  /* Converts the color to a 6-digit hex string. Unfortunately, it cannot
     handle floats very well so we'll have to round these up.

     Type: toHex :: RGB -> String

     Example:
       toHex { r = 231; g = 12; b = 21; }
       => "E70C15"
  */
  toHex = { r, g, b, ... }:
    let
      components = builtins.map (c:
        let c' = self.math.round c;
        in self.hex.pad 2 (self.hex.fromDec c')) [ r g b ];
    in lib.concatStringsSep "" components;

  /* Converts the color to a 8-digit hex string (RGBA). If no `a` component, it
     will be assumed to be at maximum value. Unfortunately, it cannot handle
     floats very well so we'll have to round these up.

     Type: toHex :: RGB -> String

     Example:
       toHex' { r = 231; g = 12; b = 21; }
       => "E70C15FF"

       toHex' { r = 231; g = 12; b = 21; a = 0; }
       => "E70C1500"
  */
  toHex' = { r, g, b, a ? valueMax, ... }:
    let
      components = builtins.map (c:
        let c' = self.math.round c;
        in self.hex.pad 2 (self.hex.fromDec c')) [ r g b a ];
    in lib.concatStringsSep "" components;

  /* Converts a valid hex string into an RGB object.

     Type: fromHex :: String -> RGB

     Example:
       fromHex "FFFFFF"
       => { r = 255; g = 255; b = 255; }

       fromHex "FFF"
       => { r = 255; g = 255; b = 255; }

       fromHex "FFFF"
       => { r = 255; g = 255; b = 255; a = 255; }

       fromHex "FFFFFFFF"
       => { r = 255; g = 255; b = 255; a = 255; }
  */
  fromHex = hex:
    let
      hex' = hexMatch hex;
      r = lib.lists.elemAt hex' 0;
      g = lib.lists.elemAt hex' 1;
      b = lib.lists.elemAt hex' 2;
      a =
        if lib.lists.length hex' == 4 then
          lib.lists.elemAt hex' 3
        else
          null;
    in RGB {
      inherit r g b;
      ${self.optionalNull (a != null) "a"} = a;
    };

  /* Given a percentage, uniformly lighten the given RGB color.

     Type: lighten :: RGB -> Number -> RGB

     Example:
       let
         color = RGB { r = 12; g = 46; b = 213; };
       in
       lighten color 50
  */
  lighten = { r, g, b, ... }:
    percentage:
    let grow' = c: self.math.grow' valueMin valueMax percentage;
    in RGB {
      r = grow' r;
      g = grow' g;
      b = grow' b;
    };

  /* Given an RGB color in hexadecimal notation, returns a list of integers
     representing each of the components in order. Certain forms of hex strings
     will also return a fourth component representing the alpha channel (RGBA).

     Type: hexMatch :: String -> List

     Example:
       hexMatch "FFF"
       => [ 255 255 255 ]

       hexMatch "FFFF"
       => [ 255 255 255 255 ]

       hexMatch "0A0B0C0D"
       => [ 10 11 12 13 ]
  */
  hexMatch = hex:
    let
      length = lib.stringLength hex;
      generateRegex = r: n:
        lib.strings.replicate r "([[:xdigit:]]{${builtins.toString n}})";
      nonAlphaGenMatch = generateRegex 3;
      withAlphaGenMatch = generateRegex 4;

      regex =
        if (length == 6) then
          nonAlphaGenMatch 2
        else if (length == 3) then
          nonAlphaGenMatch 1
        else if (length == 8) then
          withAlphaGenMatch 2
        else if (length == 4) then
          withAlphaGenMatch 1
        else
          throw "Not a valid hex code";

      scale = self.trivial.scale {
        inMin = 0;
        inMax = 15;
        outMin = valueMin;
        outMax = valueMax;
      };

      match = lib.strings.match regex hex;
      output = builtins.map (x: self.hex.toDec x) match;
    in
      if (length == 3 || length == 4) then
        builtins.map (x: scale x) output
      else
        output;
}
