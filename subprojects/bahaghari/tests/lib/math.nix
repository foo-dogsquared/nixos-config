# Being a math library implementation, we should be careful of making tests
# here to be consistent with the other math libraries. All of the answers here
# should be sourced from another tool such as a calculator.
#
# For future references, the initial maintainer (foodogsquared) basically used
# GNOME Calculator which uses libmath.
{ pkgs, lib, self }:

let
  # The typical rounding procedure for our results. 10 decimal places should be
  # enough to test accuracy at least for a basic math subset like this.
  round' = self.math.round' (-10);
in
lib.runTests {
  testMathIsOdd = {
    expr = self.math.isOdd 45;
    expected = true;
  };

  testMathIsOdd2 = {
    expr = self.math.isOdd 10;
    expected = false;
  };

  testMathIsEven = {
    expr = self.math.isEven 45;
    expected = false;
  };

  testMathIsEven2 = {
    expr = self.math.isEven 10;
    expected = true;
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

  testMathWithinRangeExclusive = {
    expr = self.math.isWithinRange' 5 10 (-5);
    expected = false;
  };

  testMathWithinRangeExclusive2 = {
    expr = self.math.isWithinRange' 5 10 10;
    expected = false;
  };

  testMathWithinRangeExclusive3 = {
    expr = self.math.isWithinRange' (-100) 100 750;
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

  testMathSqrt = {
    expr = round' (self.math.sqrt 4);
    expected = 2;
  };

  testMathSqrt2 = {
    expr = self.math.sqrt 169;
    expected = 13;
  };

  testMathSqrt3 = {
    expr = round' (self.math.sqrt 12);
    expected = 3.4641016151;
  };

  testMathSqrt4 = {
    expr = round' (self.math.sqrt 2);
    expected = 1.4142135624;
  };

  testMathMod = {
    expr = self.math.mod 5 4;
    expected = 1;
  };

  testMathMod2 = {
    expr = self.math.mod 1245 4.5;
    expected = 3;
  };

  testMathModPositiveOperands = {
    expr = self.math.mod 19 12;
    expected = 7;
  };

  testMathModNegativeDividend = {
    expr = self.math.mod (-19) 12;
    expected = 5;
  };

  testMathModNegativeDivisor = {
    expr = self.math.mod 19 (-12);
    expected = -5;
  };

  testMathModNegativeOperands = {
    expr = self.math.mod (-19) (-12);
    expected = -7;
  };

  testMathRemainder = {
    expr = self.math.remainder 65.5 3;
    expected = 2.5;
  };

  testMathRemainder2 = {
    expr = self.math.remainder 1.5 3;
    expected = 1.5;
  };

  testMathRemainder3 = {
    expr = self.math.remainder 4.25 2;
    expected = 0.25;
  };

  testMathRemainder4 = {
    expr = self.math.remainder 6 6;
    expected = 0;
  };

  testMathRemainder5 = {
    expr = self.math.remainder 6.5 6;
    expected = 0.5;
  };

  testMathRemainder6 = {
    expr = self.math.remainder 7856.5 20;
    expected = 16.5;
  };

  # Computers and their quirky floating-values implementations...
  testMathRemainder7 = {
    expr = self.math.remainder 7568639.2 45633;
    expected = 39194.200000000186;
  };

  testMathRemainder8 = {
    expr = self.math.remainder 567.5 3.5;
    expected = 0.5;
  };

  testMathRemainderPositiveOperands = {
    expr = self.math.remainder 54.5 20.5;
    expected = 13.5;
  };

  testMathRemainderNegativeDividend = {
    expr = self.math.remainder (-54.5) 20.5;
    expected = 7;
  };

  testMathRemainderNegativeDivisor = {
    expr = self.math.remainder 54.5 (-20.5);
    expected = -7;
  };

  testMathRemainderNegativeOperands = {
    expr = self.math.remainder (-54.5) (-20.5);
    expected = -13.5;
  };

  testMathExp = {
    expr = self.math.exp 1;
    expected = 2.718281828459045;
  };

  testMathExp2 = {
    expr = self.math.exp (-1);
    expected = 0.36787944117144233;
  };

  testMathExp3 = {
    expr = round' (self.math.exp 2);
    expected = 7.3890560989;
  };

  testMathExp4 = let
    round' = self.math.round' (-8);
  in {
    expr = round' (self.math.exp 8);
    expected = round' 2980.95798704;
  };

  testMathExp5 = let
    round' = self.math.round' (-8);
  in {
    expr = round' (self.math.exp 8.1);
    expected = 3294.46807528;
  };

  testMathExp6 = {
    expr = round' (self.math.exp (-9.5));
    expected = round' 0.00007485182;
  };

  testMathExpZeroIsOne = {
    expr = self.math.exp 0;
    expected = 1;
  };

  testDegreesToRadians = {
    expr = self.math.degreesToRadians 180;
    expected = self.math.constants.pi;
  };

  testDegreesToRadians2 = {
    expr = self.math.degreesToRadians 360;
    expected = self.math.constants.pi * 2;
  };

  testDegreesToRadians3 = {
    expr = self.math.round' (-5) (self.math.degreesToRadians 95);
    expected = 1.65806;
  };

  testRadiansToDegrees = {
    expr = self.math.radiansToDegrees self.math.constants.pi;
    expected = 180;
  };

  testRadiansToDegrees2 = {
    expr = self.math.round' (-3) (self.math.radiansToDegrees 180);
    expected = 10313.24;
  };

  testRadiansToDegrees3 = {
    expr = self.math.round' (-3) (self.math.radiansToDegrees 4.5);
    expected = 257.831;
  };

  # At this point, most of the things are just adjusting to the quirks of those
  # accursed floating-values.
  testMathSine = {
    expr = round' (self.math.sin 10);
    expected = round' (-0.5440211108893698);
  };

  testMathSine2 = {
    expr = self.math.sin 0;
    expected = 0;
  };

  testMathSine3 = let
    round' = self.math.round' (-5);
  in {
    expr = round' (self.math.sin (self.math.constants.pi / 2));
    expected = round' 1;
  };

  testMathSine4 = {
    expr = round' (self.math.sin 360);
    expected = round' 0.9589157234143065;
  };

  testMathSine5 = {
    expr = round' (self.math.sin 152);
    expected = round' 0.933320523748862;
  };

  testMathSine6 = {
    expr = round' (self.math.sin (-152));
    expected = round' (-0.933320523748862);
  };

  testMathCosine = {
    expr = round' (self.math.cos 10);
    expected = round' (-0.8390715290764524);
  };

  testMathCosine2 = {
    expr = round' (self.math.cos 0);
    expected = 1;
  };

  testMathCosine3 = {
    expr = round' (self.math.cos self.math.constants.pi);
    expected = -1;
  };

  testMathCosine4 = {
    expr = round' (self.math.cos (self.math.constants.pi * 2));
    expected = 1;
  };

  testMathCosine5 = {
    expr = round' (self.math.cos 1);
    expected = round' 0.5403023058681398;
  };

  testMathCosine6 = {
    expr = round' (self.math.cos 152);
    expected = round' 0.35904428689111606;
  };

  testMathTangent = {
    expr = round' (self.math.tan 10);
    expected = round' 0.6483608274590866;
  };

  testMathTangent2 = {
    expr = round' (self.math.tan 0);
    expected = 0;
  };

  testMathTangent3 = {
    expr = round' (self.math.tan (self.math.constants.pi / 4));
    expected = round' (0.99999999999999999);
  };

  testMathTangent4 = {
    expr = round' (self.math.tan 152);
    expected = round' 2.5994579438382797;
  };

  testMathTangent5 = {
    expr = round' (self.math.tan (-152));
    expected = round' (-2.5994579438382797);
  };
}
