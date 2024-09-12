{ pkgs, lib, self }:

lib.runTests {
  testCountAttrs = {
    expr = self.trivial.countAttrs (n: v: v?enable && v.enable) {
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
      notOk = { e = 5; f = 7; };
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
}
