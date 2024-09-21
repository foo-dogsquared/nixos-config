# Similar to RGB, we're also going to base our implementation from looking
# after the W3 CSS Color Module Level 4 specification simply because it is the
# most common one.
{ pkgs, lib, self }:

let inherit (self.colors) rgb;
in rec {
  valueHueMin = 0.0;
  valueHueMax = 360.0;
  valueParamMin = 0.0;
  valueParamMax = 100.0;

  /* Generates an HSL colorspace object to be generated with its method for
     convenience.

     Type: HSL :: Attrs -> Attrs

     Example:
       HSL { h = 242.0; s = 25; l = 50; }
       => {
         # The individual hue, saturation, and luminance levels.

         # And several methods.
         methods = {
           toRgb = <function>;
           lighten = <function>;
         };
       }
  */
  HSL = { h, s, l, ... }@color:
    assert lib.assertMsg (isHsl color)
      "bahaghariLib.colors.hsl.HSL: given color does not have valid HSL value";
    {
      inherit h s l;
    } // lib.optionalAttrs (color ? a) { inherit (color) a; };

  /* Returns a boolean if the object is a valid HSL Nix object.

     Type: isHsl :: Attrs -> Bool

     Example:
       isHsl { h = 43; s = 89; l = 79; }
       => true

       # The hue value is over 360 so it isn't valid.
       isHsl { h = 467; s = 78; l = 50; }
       => false

       # The lightness is over 100 so not valid either.
       isHsl { h = 360; s = 86; l = 120; }
       => false
  */
  isHsl = { h, s, l, ... }@color:
    let
      isValidHue = self.math.isWithinRange valueHueMin valueHueMax;
      isValidPercentage = self.math.isWithinRange valueParamMin valueParamMax;
    in
      isValidHue h && isValidPercentage s && isValidPercentage l;

  /* Converts an HSL object to RGB instance.

     Formula is directly taken from the following resource:
     https://www.rapidtables.com/convert/color/hsl-to-rgb.html

     Type: toRgb :: Attrs -> Attrs

     Example:
       toRgb { h = 234; s = 65; l = 73; }
       => { r = 43; g = 52; b = 56 }
  */
  toRgb = { h, s, l, ... }@color:
    let
      inherit (self.colors.rgb) RGB valueMax;
      inherit (self.math) abs sub remainder round;

      l' = l / valueParamMax;
      s' = s / valueParamMax;

      # This may as well turn into Scheme code.
      C = (1 - (abs ((2 * l') - 1))) * s';
      X = C * (1 - (abs (sub (remainder (h / 60.0) 2) 1)));
      m = l' - (C / 2);

      isHueWithin = min: max:
        (h >= min) && (h < max);
      rgb' =
        if (isHueWithin 0 60) then
          { r = C; g = X; b = 0; }
        else if (isHueWithin 60 120) then
          { r = X; g = C; b = 0; }
        else if (isHueWithin 120 180) then
          { r = 0; g = C; b = X; }
        else if (isHueWithin 180 240) then
          { r = 0; g = X; b = C; }
        else if (isHueWithin 240 300) then
          { r = X; g = 0; b = C; }
        else if (isHueWithin 300 360) then
          { r = C; g = 0; b = X; }
        else throw "WHAT IN THE HELL";

      scaleValue = x: round ((x + m) * valueMax);
    in
      RGB {
        r = scaleValue rgb'.r;
        g = scaleValue rgb'.g;
        b = scaleValue rgb'.b;
      };

  /* Converts an HSL object into an RGB hex string.

     Type: toHex :: Attrs -> String

     Example:
       toHex { h = 34; s = 76; l = 100; }
       => "FFFFFF"
  */
  toHex = color: rgb.toHex (toRgb color);

  /* Converts an HSL object into an RGBA hex string.

     Type: toHex :: Attrs -> String

     Example:
       toHex { h = 34; s = 76; l = 100; }
       => "FFFFFF"
  */
  toHex' = color: rgb.toHex' (toRgb color);

  lighten = { h, s, l, ... }:
    percentage:
    HSL {
      inherit h s;
      l = l + percentage;
    };
}
