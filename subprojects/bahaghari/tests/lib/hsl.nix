{ pkgs, lib, self }:

let
  inherit (self.colors.rgb) RGB;
  inherit (self.colors.hsl) HSL;

  hslSample = HSL {
    h = 254;
    s = 100;
    l = 45;
  };
in lib.runTests {
  testsBasicHsl = {
    expr = HSL {
      h = 245;
      s = 16;
      l = 60;
    };
    expected = {
      h = 245;
      s = 16;
      l = 60;
    };
  };

  testsBasicHsl2 = {
    expr = HSL {
      h = 350;
      s = 16;
      l = 60;
      a = 100;
    };
    expected = {
      h = 350;
      s = 16;
      l = 60;
      a = 100;
    };
  };

  testsToRgb = {
    expr = self.colors.hsl.toRgb hslSample;
    expected = RGB {
      r = 54;
      g = 0;
      b = 230;
    };
  };

  testsToHex = {
    expr = self.colors.hsl.toHex hslSample;
    expected = "3600E6";
  };

  testsToHex' = {
    expr = self.colors.hsl.toHex' hslSample;
    expected = "3600E6FF";
  };
}
