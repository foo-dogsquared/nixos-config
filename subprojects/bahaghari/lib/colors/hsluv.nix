# HSLuv implementation in Nix. This is taken from the reference implementation,
# specifically from the JavaScript implementation at
# https://github.com/hsluv/hsluv-javascript.
{ pkgs, lib, self }:

let
  inherit (self.colors) rgb hsl;

  refY = 1.0;
  refU = 0.19783000664283;
  refV = 0.46831999493879;
  kappa = 903.2962962;
  epsilon = 0.0088564516;

  m = {
    r = [ 3.240969941904521 (-1.537383177570093) (-0.498610760293) ];
    g = [ (-0.96924363628087) 1.87596750150772 0.041555057407175 ];
    b = [ 0.055630079696993 (-0.20397695888897) 1.056971514242878 ];
  };

  fromLinear = number:
     if number <= 0.0031308 then
        12.92 * number
      else
        1.055 * (self.math.pow number (1 / 2.4)) - 0.055;

  toLinear = number:
    if number > 0.04045 then
      self.math.pow ((number + 0.055) / 1.055) 2.4
    else
      number / 12.92;
in
rec {
  inherit (hsl) valueHueMin valueHueMax valueParamMin valueParamMax;

  HSLuv = color: {};

  toRgb = { h, s, l, ... }@color: {

  };

  toHex = color: rgb.toHex (toRgb color);

  toHex' = color: rgb.toHex' (toRgb color);
}
