{ pkgs, lib }:

pkgs.lib.runTests {
  testMathPowPositive = {
    expr = lib.math.pow 2 8;
    expected = 256;
  };

  testMathPowNegative = {
    expr = lib.math.pow 2.0 (-1);
    expected = 0.5;
  };

  testMathPowZero = {
    expr = lib.math.pow 34 0;
    expected = 1;
  };

  testMathAbsoluteValue = {
    expr = lib.math.abs 5493;
    expected = 5493;
  };

  testMathAbsoluteValue2 = {
    expr = lib.math.abs (-435354);
    expected = 435354;
  };

  testMathPercentage = {
    expr = lib.math.percentage 100 50;
    expected = 50;
  };

  testMathPercentage2 = {
    expr = lib.math.percentage 453 13;
    expected = 58.89;
  };

  testMathGrow = {
    expr = lib.math.grow 500 12;
    expected = 72;
  };

  testMathGrow2 = {
    expr = lib.math.grow 55.5 5.5;
    expected = 8.5525;
  };

  testMathGrowVariantMax = {
    expr = lib.math.grow' 0 255 130 100;
    expected = 255;
  };

  testMathGrowVariantMin = {
    expr = lib.math.grow' 0 255 130 (-500);
    expected = 0;
  };

  testMathRoundDown = {
    expr = lib.math.round 2.3;
    expected = 2;
  };

  testMathRoundUp = {
    expr = lib.math.round 2.8;
    expected = 3;
  };

  testMathWithinRange = {
    expr = lib.math.isWithinRange (-100) 100 50;
    expected = true;
  };

  testMathWithinRange2 = {
    expr = lib.math.isWithinRange 5 10 (-5);
    expected = false;
  };
}
