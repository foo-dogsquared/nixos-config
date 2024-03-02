# A small utility library for manipulating hexadecimal numbers. It's made in 15
# minutes with a bunch of duct tape on it but it's working for its intended
# purpose.
{ pkgs, lib, self }:

let
  glyphList =
    [
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
      "A"
      "B"
      "C"
      "D"
      "E"
      "F"
    ];

  baseSet = self.generateBaseDigitType glyphList;
in
rec {
  /* Returns a convenient glyph set for creating your own conversion or
     hex-related functions.
  */
  inherit (baseSet) glyphSet conversionTable fromDec toDec;

  /* A variant of `lib.lists.range` function just with hexadecimal digits.

    Type: range :: Int -> Int -> [ String ]

    Example:
      range 15 18
      => [ "F" "10" "11" ]
  */
  range = first: last:
    builtins.map (n: baseSet.fromDec n) (lib.lists.range first last);

  /* Checks if the given hex string is valid or not.

     Type: isHexString :: String -> Bool

     Example:
       isHexString "ABC"
       => true

       isHexString "00ABC"
       => true

       isHexString "WHAT! HELL NO!"
       => false
  */
  isHexString = hex:
    builtins.match "[A-Fa-f0-9]+" hex != null;

  /* Left pads the given hex number with the given number of max amount of
     digits. It will throw an error if it's not a hex string.

     Type: pad :: Int -> String -> String

     Example:
       pad 2 "A"
       => "0A"

       pad 1 "ABC"
       => "ABC"

       pad -2 "ABC"
       => "ABC"
  */
  pad = n: hex:
    let
      strLength = lib.stringLength hex;
      reqWidth = n - strLength;
      components = lib.genList (_: "0") reqWidth ++ [ hex ];
    in
    assert lib.assertMsg (isHexString hex)
      "bahaghariLib.hex.pad: given hex number (${hex}) is not valid";
    if (reqWidth <= 0)
    then hex
    else lib.concatStringsSep "" components;
}
