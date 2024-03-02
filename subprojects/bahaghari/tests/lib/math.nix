{ pkgs, lib, self }:

lib.runTests {
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

  testMathAbsoluteValue = {
    expr = self.math.abs 5493;
    expected = 5493;
  };

  testMathAbsoluteValue2 = {
    expr = self.math.abs (-435354);
    expected = 435354;
  };

  testMathPercentage = {
    expr = self.math.percentage 50 100;
    expected = 50;
  };

  testMathPercentage2 = {
    expr = self.math.percentage 13 453;
    expected = 58.89;
  };

  testMathPercentageNegative = {
    expr = self.math.percentage (-20) 500;
    expected = -100;
  };

  testMathPercentageNegative2 = {
    expr = self.math.percentage (-64) 843;
    expected = -539.52;
  };

  testMathPercentageZero = {
    expr = self.math.percentage 0 45723;
    expected = 0;
  };

  testMathPercentageZero2 = {
    expr = self.math.percentage 0 (-3423);
    expected = 0;
  };

  testMathGrow = {
    expr = self.math.grow 500 12;
    expected = 72;
  };

  testMathGrow2 = {
    expr = self.math.grow 55.5 5.5;
    expected = 8.5525;
  };

  testMathGrowVariantMax = {
    expr = self.math.grow' 0 255 130 100;
    expected = 255;
  };

  testMathGrowVariantMin = {
    expr = self.math.grow' 0 255 130 (-500);
    expected = 0;
  };

  testMathRoundDown = {
    expr = self.math.round 2.3;
    expected = 2;
  };

  testMathRoundUp = {
    expr = self.math.round 2.8;
    expected = 3;
  };

  testMathWithinRange = {
    expr = self.math.isWithinRange (-100) 100 50;
    expected = true;
  };

  testMathWithinRange2 = {
    expr = self.math.isWithinRange 5 10 (-5);
    expected = false;
  };
}
