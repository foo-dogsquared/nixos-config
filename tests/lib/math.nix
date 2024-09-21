{ pkgs, lib, self }:


lib.runTests {
  testMathAbsoluteValue = {
    expr = self.math.abs 5493;
    expected = 5493;
  };

  testMathAbsoluteValue2 = {
    expr = self.math.abs (-435354);
    expected = 435354;
  };

  testMathPowPositive = {
    expr = self.math.pow 2 8;
    expected = 256;
  };

  testMathPowNegative = {
    expr = self.math.pow 2.0 (-1);
    expected = 0.5;
  };

  testMathPowZero = {
    expr = self.math.pow 31 0;
    expected = 1;
  };

  testsMathPowWithFloat = {
    expr = self.math.pow 2 7.0;
    expected = 128.0;
  };
}
