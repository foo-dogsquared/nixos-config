{ pkgs, lib }:

pkgs.lib.runTests {
  testToHexString = {
    expr = lib.hex.fromDec 293454837;
    expected = "117DC3F5";
  };

  testToHexString2 = {
    expr = lib.hex.fromDec 4500;
    expected = "1194";
  };

  testToHexString3 = {
    expr = lib.hex.fromDec 5942819;
    expected = "5AAE23";
  };

  testHexToDec = {
    expr = lib.hex.toDec "FF";
    expected = 255;
  };

  testHexToDec2 = {
    expr = lib.hex.toDec "333FAB333";
    expected = 13756969779;
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
