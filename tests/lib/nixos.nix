{ pkgs, lib, self }:

let
  testConfig = {
    formatAttr = "isoImage";
  };
in
lib.runTests {
  testNixSystemHasFormat = {
    expr = self.nixos.hasNixosFormat testConfig;
    expected = true;
  };

  testNixSystemNoFormat = {
    expr = self.nixos.hasNixosFormat { };
    expected = false;
  };

  testNixSystemFormatCompare = {
    expr = self.nixos.isFormat testConfig "isoImage";
    expected = true;
  };

  testNixSystemFormatCompare2 = {
    expr = self.nixos.isFormat { } "isoImage";
    expected = false;
  };
}
