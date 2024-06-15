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

    # The minimum precision for our functions that need them.
    epsilon = pow 10 (-13);
  };

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
    # I'll just make this as a tail recursive function instead.
    let
      absValue = abs exponent;
      iter = product: counter: max-count:
        if counter > max-count
        then product
        else iter (product * base) (counter + 1) max-count;
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
    pow constants.e x;

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
    let
      res = grow number value;
    in
      lib.min max (lib.max res min);

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
  round = number:
    round' 0 number;

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

  /* Similar to the nixpkgs' `trivial.mod` but retain the decimal values. This
     is just an approximation from ECMAScript's implementation of the modulo
     operator (%).

     Type: mod' :: Number -> Number -> Number

     Example:
       mod' 4.25 2
       => 0.25

       mod' 1.5 2
       => 1.5

       mod' 65 5
       => 0

       mod' (-54) 4
       => -2

       mod' (-54) (-4)
       => -2
  */
  mod' = base: number:
    let
      base' = abs base;
      number' = abs number;
      difference = number' * ((floor base' / (floor number')) + 1);

      result = number' - (difference - base');
    in
      if number' > base' then
        base
      else
        if base < 0 then
          -(result)
        else
          result;

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
}
