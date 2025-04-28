# A little math utility for common operations. Don't expect any high-level
# mathematical operations nor godly optimizations expected from a typical math
# library, it's just basic high school type of shit in all aspects.
{ pkgs, lib, self }:

rec {
  # We have the rounding functions here anyways so we may as well include the
  # rest of the decimal place changing functions here for consistency.
  inherit (builtins) floor ceil;

  constants = {
    pi = 3.141592653589793238462643383279502884197;
    e = 2.7182818284590452353602874713527;
    ln10 = 2.302585092994046;
    ln2 = 0.6931471805599453;

    # The precision target for our functions that need them.
    epsilon = pow 0.1 13;
  };

  # TODO: We may need to export these functions as a separate Nix library.
  /* Given a number, check if it's an even number.

     Type: isEven :: Int -> Int

     Example:
      isEven 10
      => true

      isEven 13
      => false
  */
  isEven = x:
    (builtins.bitAnd x 1) == 0;

  /* Given a number, check if it's an odd number.

     Type: isOdd :: Int -> Int

     Example:
      isOdd 10
      => true

      isOdd 13
      => false
  */
  isOdd = x: !(isEven x);

  /* Returns the absolute value of the given number.

     Type: abs :: Int -> Int

     Example:
       abs -4
       => 4

       abs (1 / 5)
       => 0.2
  */
  abs = number:
    if number < 0 then -(number) else number;

  /* Exponentiates the given base with the exponent.

     Type: pow :: Int -> Int -> Int

     Example:
       pow 2 3
       => 8

       pow 6 4
       => 1296
  */
  pow = base: exponent:
    # Just to be a contrarian, I'll just make this as a tail recursive function
    # instead lol.
    let
      absValue = abs exponent;
      iter = product: counter: maxCount:
        if counter > maxCount
        then product
        else iter (product * base) (counter + 1) maxCount;
      value = iter 1 1 absValue;
    in
    if exponent < 0 then (1 / value) else value;

  /* Given a number as x, return e^x.

     Type: exp :: Number -> Number

     Example:
       exp 0
       => 1

       exp 1
       => 2.7182818284590452353602874713527

       exp -1
       => 0.36787944117144233
  */
  exp = x:
    let
      inherit (constants) epsilon e ln2;

      taylorExp = x: n: sum:
        let
          term = (pow x n) / (factorial n);
          newSum = sum + term;
        in
        if term < epsilon then newSum
        else taylorExp x (n + 1) newSum;
    in
    if x == 0 then 1
    else if x == 1 then e
    else if x < 0 then 1 / (exp (-x))
    else
      let
        # Range reduction: x = k*ln2 + r
        k = floor (x / ln2);
        r = x - k * ln2;
        # Calculate exp(r) using Taylor series
        expR = taylorExp r 0 0;
      in
        expR * (pow 2 k);

  /* Given a number, find its square root. This method is implemented using
     Newton's method.

     Type: sqrt :: Number -> Number

     Example:
       sqrt 4
       => 2

       sqrt 169
       => 13

       sqrt 12
       => 3.464101615
  */
  sqrt = number:
    assert lib.assertMsg (number >= 0)
      "bahaghariLib.math.sqrt: Only positive numbers are allowed";
    let
      # Changing this value can change the result drastically. A value of
      # 10^-13 for tolerance seems to be the most balanced so far since we are
      # dealing with floats and should be enough for most cases.
      tolerance = constants.epsilon;

      iter = value:
        let
          root = 0.5 * (value + (number / value));
        in
          if (abs (root - value) > tolerance) then
            iter root
          else
            value;
    in
      iter number;

  /* Implements the factorial function with the given value.

     Type: factorial :: Number -> Number

     Example:
       factorial 3
       => 6

       factorial 10
       => 3628800
  */
  factorial = x:
    assert lib.assertMsg (x >= 0)
      "bahaghariLib.math.factorial: Given value is not a positive integer";
    product (lib.range 1 x);

  /* Returns a boolean whether the given number is within the given (inclusive) range.

     Type: isWithinRange :: Number -> Number -> Number -> Bool

     Example:
       isWithinRange 30 50 6
       => false

       isWithinRange 0 100 75
       => true
  */
  isWithinRange = min: max: number:
    (lib.max number min) <= (lib.min number max);

  /* Returns a boolean whether the given number is within the given (exclusive) range.

     Type: isWithinRange :: Number -> Number -> Number -> Bool

     Example:
       isWithinRange 30 50 6
       => false

       isWithinRange 0 100 75
       => true
  */
  isWithinRange' = min: max: number:
    (lib.max number min) < (lib.min number max);

  /* Given a number, make it grow by given amount of percentage.
     A value of 100 should make the number doubled.

     Type: grow :: Number -> Number -> Number

     Example:
       grow 4 50.0
       => 2

       grow 55.5 100
       => 111
  */
  grow = value: number:
    number + (percentage number value);

  /* Similar to `grow` but only limits to be within the given (inclusive)
     range.

     Type: grow' :: Number -> Number -> Number -> Number

     Example:
       grow' 0 255 12 100
       => 24

       grow' 1 10 5 (-200)
       => 1
  */
  grow' = min: max: value: number:
    self.trivial.clamp min max (grow number value);

  /* Given a number, return its value by the given percentage.

     Type: percentage :: Number -> Number -> Number

     Example:
       percentage 100.0 4
       => 4

       percentage 200.0 5
       => 10

       percentage 55.4 58
       => 32.132

       percentage 0 24654
       => 0
  */
  percentage = value: number:
    if value == 0
    then 0
    else number / (100.0 / value);

  /* Given a number, round up (or down) its number to the nearest ones place.

     Type: round :: Number -> Number

     Example:
       round 3.5
       => 4

       round 2.3
       => 2

       round 2.7
       => 3
  */
  round = round' 0;

  /* Given a tens place (10 ^ n) and a number, round the nearest integer to its
     given place.

     Type: round' :: Number -> Number -> Number

     Example:
       # Round the number to the nearest ones.
       round' 0 5.65
       => 6

       # Round the number to the nearest tens.
       round' 1 5.65
       => 10

       # Round the number to the nearest hundreds.
       round' 2 5.65
       => 0

       # Round the number to the nearest tenth.
       round' (-1) 5.65
       => 5.7
  */
  round' = tens: number:
    let
      nearest = pow 10.0 tens;
      difference = number / nearest;
    in
      floor (difference + 0.5) * nearest;

  /* Given a base and a modulus, returns the value of a modulo operation.

     Type: mod :: Number -> Number -> Number

     Example:
       mod 5 4
       => 1

       mod 1245 4.5
       => 3

       mod 19 (-12)
       => -5
  */
  mod = base: modulus:
    remainder ((remainder base modulus) + modulus) modulus;

  /* Similar to the nixpkgs' `trivial.mod` but retain the decimal values. This
     is just an approximation from ECMAScript's implementation of the remainder
     operator.

     Type: remainder :: Number -> Number -> Number

     Example:
       remainder 4.25 2
       => 0.25

       remainder 1.5 2
       => 1.5

       remainder 65 5
       => 0

       remainder (-54) 4
       => -2

       remainder (-54) (-4)
       => -2
  */
  remainder = dividend: divisor:
    let
      quotient = dividend / divisor;
    in
      dividend - ((floor quotient) * divisor);

  /* Adds all of the given items on the list starting from a sum of zero.

     Type: summate :: List[Number] -> Number

     Example:
       summate [ 1 2 3 4 ]
       => 10
  */
  summate = builtins.foldl' builtins.add 0;

  /* Multiply all of the given items on the list starting from a product of 1.

     Type: product :: List[Number] -> Number

     Example:
       product [ 1 2 3 4 ]
       => 24
  */
  product = builtins.foldl' builtins.mul 1;

  # The following trigonometric functions is pretty much sourced from the following link.
  # https://lantian.pub/en/article/modify-computer/nix-trigonometric-math-library-from-zero.lantian/

  /* Given a number in radians, return the value applied with a sine function.

     Type: sin :: Number -> Number

     Example:
       sin 10
       => -0.5440211108893698

       sin (constants.pi / 2)
       => 1
  */
  sin = x: let
    x' = mod (toFloat x) (2 * constants.pi);
    step = i: (pow (-1) (i - 1)) * product (lib.genList (j: x' / (j + 1)) (i * 2 - 1));
    iter = value: counter: let
      value' = step counter;
    in
      if (abs value') < constants.epsilon
      then value
      else iter (value' + value) (counter + 1);
  in
    if x < 0
    then -(sin (-x))
    else iter 0 1;

  /* Given a number in radians, apply the cosine function.

     Type: cos :: Number -> Number

     Example:
       cos 10
       => -0.8390715290764524

       cos 0
       => 1
  */
  cos = x: sin (0.5 * constants.pi - x);

  /* Given a number in radians, apply the tan trigonometric function.

     Type: tan :: Number -> Number

     Example:
       tan 0
       => 0

       tan 10
       => 0.6483608274590866
  */
  tan = x: (sin x) / (cos x);

  /* Given a number in radians, convert it to degrees.

     Type: radiansToDegrees :: Number -> Number

     Example:
       radiansToDegrees bahaghariLib.math.constants.pi
       => 180

       radiansToDegrees 180
       => 10313.240312355
  */
  radiansToDegrees = x:
    x * 180.0 / constants.pi;

  /* Given a number in degrees unit, convert it to radians.

     Type: degreesToRadians :: Number -> Number

     Example:
       degreesToRadians 180
       => 3.141592653589793238462643383279502884197

       degreesToRadians 360
       => 6.283185307

       degreesToRadians 95
       => 1.658062789
  */
  degreesToRadians = x:
    x * constants.pi / 180.0;
}
