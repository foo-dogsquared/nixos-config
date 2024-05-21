{ pkgs, lib, self }:

let
  # A modified version that simply removes the functor to focus more on the
  # actual results. Also, it will mess up the result comparison since comparing
  # functions is reference-based so it will always fail.
  normalizeData = colors:
    lib.attrsets.removeAttrs colors [ "__functor" ];

  rgbSample = self.colors.rgb.RGB {
    r = 255;
    g = 255;
    b = 255;
  };

  # A modified version of RGB that normalizes data out-of-the-boxly.
  RGB = colors: normalizeData (self.colors.rgb.RGB colors);
in
lib.runTests {
  testsBasicRgb = {
    expr = RGB {
      r = 34;
      g = 2;
      b = 0;
    };
    expected = {
      r = 34;
      g = 2;
      b = 0;
    };
  };

  testsFromHex = {
    expr = normalizeData (self.colors.rgb.fromHex "FFFFFF");
    expected = normalizeData (self.colors.rgb.RGB {
      r = 255;
      g = 255;
      b = 255;
    });
  };

  testsFromHex2 = {
    expr = normalizeData (self.colors.rgb.fromHex "FFF");
    expected = normalizeData (self.colors.rgb.RGB {
      r = 255;
      g = 255;
      b = 255;
    });
  };

  testsFromHex3 = {
    expr = normalizeData (self.colors.rgb.fromHex "FFFF");
    expected = normalizeData (self.colors.rgb.RGB {
      r = 255;
      g = 255;
      b = 255;
    });
  };

  testsFromHex4 = {
    expr = normalizeData (self.colors.rgb.fromHex "FFFFFFFF");
    expected = normalizeData (self.colors.rgb.RGB {
      r = 255;
      g = 255;
      b = 255;
    });
  };

  testsToHex = {
    expr = self.colors.rgb.toHex rgbSample;
    expected = "FFFFFF";
  };

  testsToHex2 = {
    expr = self.colors.rgb.toHex (RGB {
      r = 23;
      g = 58;
      b = 105;
    });
    expected = "173A69";
  };

  testsHexMatch = {
    expr = self.colors.rgb.hexMatch "FFF";
    expected = [ 255 255 255 ];
  };

  testsHexMatch2 = {
    expr = self.colors.rgb.hexMatch "FFFF";
    expected = [ 255 255 255 255 ];
  };

  testsHexMatch3 = {
    expr = self.colors.rgb.hexMatch "0A0B0C0D";
    expected = [ 10 11 12 13 ];
  };

  testsHexMatch4 = {
    expr = self.colors.rgb.hexMatch "0A0B0C";
    expected = [ 10 11 12 ];
  };
}
