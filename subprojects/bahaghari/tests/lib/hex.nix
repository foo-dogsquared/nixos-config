{ pkgs, lib }:

pkgs.lib.runTests {
  testToHexString = {
    expr = lib.hex.toHexString 293454837;
    expected = "117DC3F5";
  };

  testCreateHexRange = {
    expr = lib.hex.range 10 17;
    expected = [ "A" "B" "C" "D" "E" "F" "10" "11" ];
  };

  testCreateHexWithHigherStart = {
    expr = lib.hex.range 49 17;
    expected = [ ];
  };

  testIsHexString = {
    expr = lib.hex.isHexString "ABC";
    expected = true;
  };

  testIsHexStringWithInvalidHex = {
    expr = lib.hex.isHexString "WHAT IS THIS";
    expected = false;
  };

  testHexPad = {
    expr = lib.hex.pad 5 "A";
    expected = "0000A";
  };

  testHexPadWithLowerMaxDigits = {
    expr = lib.hex.pad 1 "9AC";
    expected = "9AC";
  };

  testHexPadWithNegativeDigits = {
    expr = lib.hex.pad (-5) "A42C";
    expected = "A42C";
  };
}
