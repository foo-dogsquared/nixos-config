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

  testsMathPowWithFloat = {
    expr = self.math.pow 2 7.0;
    expected = 128.0;
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

  testMathFloor = {
    expr = self.math.floor 3.467;
    expected = 3;
  };

  testMathFloor2 = {
    expr = self.math.floor 3.796;
    expected = 3;
  };

  testMathCeil = {
    expr = self.math.ceil 3.469;
    expected = 4;
  };

  testMathCeil2 = {
    expr = self.math.ceil 3.796;
    expected = 4;
  };

  testMathRoundDown = {
    expr = self.math.round 2.3;
    expected = 2;
  };

  testMathRoundUp = {
    expr = self.math.round 2.8;
    expected = 3;
  };

  testMathRoundOnes = {
    expr = self.math.round' 0 5.65;
    expected = 6;
  };

  testMathRoundTens = {
    expr = self.math.round' 1 5.65;
    expected = 10;
  };

  testMathRoundHundreds = {
    expr = self.math.round' 2 5.65;
    expected = 0;
  };

  testMathRoundTenth = {
    expr = self.math.round' (-1) 5.65;
    expected = 5.7;
  };

  testMathRoundHundredth = {
    expr = self.math.round' (-2) 5.655;
    expected = 5.66;
  };

  testMathWithinRange = {
    expr = self.math.isWithinRange (-100) 100 50;
    expected = true;
  };

  testMathWithinRange2 = {
    expr = self.math.isWithinRange 5 10 (-5);
    expected = false;
  };

  testMathFactorial = {
    expr = self.math.factorial 3;
    expected = 6;
  };

  testMathFactorial2 = {
    expr = self.math.factorial 10;
    expected = 3628800;
  };

  testMathFactorialZero = {
    expr = self.math.factorial 0;
    expected = 1;
  };

  testMathSummate = {
    expr = self.math.summate [ 1 2 3 4 ];
    expected = 10;
  };

  testMathSummate2 = {
    expr = self.math.summate [ 1 2 3 4.5 5.6 6.7 ];
    expected = 22.8;
  };

  testMathProduct = {
    expr = self.math.product [ 1 2 3 4 ];
    expected = 24;
  };

  testMathProduct2 = {
    expr = self.math.product [ 1.5 2 3 4.6 ];
    expected = 41.4;
  };

  # All of the answers here should be sourced from another tool such as a
  # calculator.
  testMathSqrt = {
    expr = self.math.sqrt 4;
    expected = 2;
  };

  testMathSqrt2 = {
    expr = self.math.sqrt 169;
    expected = 13;
  };

  testMathSqrt3 = {
    expr = self.math.round' (-9) (self.math.sqrt 12);
    expected = 3.464101615;
  };

  testMathSqrt4 = {
    expr = self.math.round' (-10) (self.math.sqrt 2);
    expected = 1.4142135624;
  };
}
