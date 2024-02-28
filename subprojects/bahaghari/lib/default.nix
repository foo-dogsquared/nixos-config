# Bahaghari's set of library. This requires nixpkgs' package set which has its
# library anyways. This set is mostly copied over from nixpkgs' way of doing
# things.
#
# Take note the `lib` attribute throughout all of the library files are
# referring to the Bahaghari library set. We mostly rely on `pkgs.lib` as an
# easy way to identify if we use nixpkgs' standard library.
{ pkgs }:

pkgs.lib.makeExtensible
  (self:
  let
    callLibs = file: import file { lib = self; inherit pkgs; };
  in
  {
    trivial = callLibs ./trivial.nix;
    hex = callLibs ./hex.nix;

    # Dedicated module sets are not supposed to have any of its functions as
    # a top-level attribute.
    tinted-theming = callLibs ./tinted-theming.nix;

    inherit (self.trivial) importYAML toYAML toBaseDigitsWithGlyphs
      generateGlyphSet generateConversionTable generateBaseDigitType pow;

    inherit (self.hex) isHexString;
  })
