# Bahaghari's set of library. This requires nixpkgs' package set which has its
# library anyways. This set is mostly copied over from nixpkgs' way of doing
# things.
#
# Take note the `lib` attribute throughout all of the library files are
# referring to the Bahaghari library set. We mostly rely on `pkgs.lib` as an
# easy way to identify if we use nixpkgs' standard library.
#
# As a design constraint, since this is expected to be evaluated modularly, we
# cannot have functions that is expected to be used in `imports` module
# attribute such as functions generating a nixpkgs module. Otherwise, we'll
# have one of those dastardly infinite recursion error and we'll be requiring
# the users to import them through the `specialArgs` module argument. In other
# words, this is a strict utility library that is fully usable outside of
# nixpkgs module system which is a happy accident. Hoorah for me?
#
# And another thing, keep the `pkgs` usage down to a minimum and select the
# most oft-used packages as much as possible. We want Bahaghari to be a good
# citizen of the Nix ecosystem after all and as a result, we have happy users
# and happy dev running in a rainbow la-la land.
{ pkgs }:

pkgs.lib.makeExtensible
  (self:
  let
    callLibs = file: import file { inherit (pkgs) lib; inherit pkgs self; };
  in
  {
    trivial = callLibs ./trivial.nix;
    hex = callLibs ./hex.nix;
    math = callLibs ./math.nix;

    # Dedicated module sets are not supposed to have any of its functions as a
    # top-level attribute. It's to make things a bit easier to organize and
    # maintain. Plus, if there's any functions that are easily applicable
    # outside of the module set it represents, it should be moved outside of
    # the namespace.
    tinted-theming = callLibs ./tinted-theming.nix;

    inherit (self.trivial) importYAML toYAML toBaseDigitsWithGlyphs
      generateGlyphSet generateConversionTable generateBaseDigitType clamp
      isNumber scale;

    inherit (self.hex) isHexString;
    inherit (self.math) abs pow percentage;
  })
