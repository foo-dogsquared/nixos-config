# Math subset.
{ pkgs, lib, self }:

rec {
  /* Returns the absolute value of the given number.

     Example:
       abs -4
       => 4

       abs (1 / 5)
       => 0.2
  */
  abs = number:
    if number < 0 then -(number) else number;
  /* Exponentiates the given base with the exponent.

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
}
