# Bahaghari's set of library. This requires nixpkgs' package set which has its
# library anyways. This set is mostly copied over from nixpkgs' way of doing
# things.
{ pkgs }:

# Take note the `lib` attribute throughout all of the library files are
# referring to the Bahaghari library set. We mostly rely on `pkgs.lib` as an
# easy way to identify if we use nixpkgs' standard library.
pkgs.lib.makeExtensible
  (self:
    let
      callLibs = file: import file { lib = self; inherit pkgs; };
    in
    {
      trivial = callLibs ./trivial.nix;
      hex = callLibs ./hex.nix;
      tinted-theming = callLibs ./tinted-theming.nix;

      inherit (self.trivial) importYAML toYAML toBaseDigitsWithGlyphs;
      inherit (self.hex) toHexString;
    })
