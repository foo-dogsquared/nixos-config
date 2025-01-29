{ pkgs, lib, self }:

lib.runTests {
  testToFloat = {
    expr = self.trivial.toFloat 4;
    expected = 4.0;
  };

  testToFloat2 = {
    expr = self.trivial.toFloat 5.5;
    expected = 5.5;
  };

  testCountAttrs = {
    expr = self.trivial.countAttrs (n: v: v ? enable && v.enable) {
      hello.enable = true;
      what.enable = false;
      atro.enable = true;
      adelie = { };
      world = "there";
      mo = null;
    };
    expected = 2;
  };

  testFilterAttrs' = {
    expr = self.trivial.filterAttrs' (n: v: v == 4) {
      e = 5;
      f = 7;
      a = 4;
    };
    expected = {
      ok = { a = 4; };
      notOk = {
        e = 5;
        f = 7;
      };
    };
  };

  testSIPrefixExponent = {
    expr = self.trivial.SIPrefixExponent "M";
    expected = 6;
  };

  testSIPrefixExponent2 = {
    expr = self.trivial.SIPrefixExponent "G";
    expected = 9;
  };

  testMetricPrefixMultiplier = {
    expr = self.trivial.metricPrefixMultiplier "M";
    expected = 1000000;
  };

  testMetricPrefixMultiplier2 = {
    expr = self.trivial.metricPrefixMultiplier "G";
    expected = 1000000000;
  };

  testBinaryPrefixMultiplier = {
    expr = self.trivial.binaryPrefixMultiplier "M";
    expected = 1048576;
  };

  testBinaryPrefixExponent = {
    expr = self.trivial.binaryPrefixExponent "M";
    expected = 20;
  };

  testBinaryPrefixExponent2 = {
    expr = self.trivial.binaryPrefixExponent "G";
    expected = 30;
  };

  testBinaryPrefixMultiplier2 = {
    expr = self.trivial.binaryPrefixMultiplier "K";
    expected = 1024;
  };

  testBinaryPrefixMultiplier3 = {
    expr = self.trivial.binaryPrefixMultiplier "G";
    expected = 1073741824;
  };

  testParseBytesSizeIntoInt = {
    expr = self.trivial.parseBytesSizeIntoInt "3GB";
    expected = 3 * (self.trivial.metricPrefixMultiplier "G");
  };

  testParseBytesSizeIntoInt2 = {
    expr = self.trivial.parseBytesSizeIntoInt "5MiB";
    expected = 5 * (self.trivial.binaryPrefixMultiplier "M");
  };

  testParseBytesSizeIntoInt3 = {
    expr = self.trivial.parseBytesSizeIntoInt "5MB";
    expected = 5 * (self.trivial.metricPrefixMultiplier "M");
  };

  testParseBytesSizeIntoInt4 = {
    expr = self.trivial.parseBytesSizeIntoInt "2 TiB";
    expected = 2 * (self.trivial.binaryPrefixMultiplier "T");
  };

  testParseBytesSizeIntoInt5 = {
    expr = self.trivial.parseBytesSizeIntoInt "2 Tib";
    expected = 2 * (self.trivial.binaryPrefixMultiplier "T") / 8;
  };

  testUnitsToInt = {
    expr = self.trivial.unitsToInt {
      size = 4.5;
      prefix = "G";
      type = "metric";
    };
    expected = 4500000000;
  };

  testUnitsToInt2 = {
    expr = self.trivial.unitsToInt {
      size = 4.5;
      prefix = "G";
    };
    expected = 4831838208;
  };

  testUnitsToInt3 = {
    expr = self.trivial.unitsToInt {
      size = 532;
      prefix = "M";
      type = "metric";
    };
    expected = 532000000;
  };
}
