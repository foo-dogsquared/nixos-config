{ pkgs, lib, self }:

lib.runTests {
  testToHexString = {
    expr = self.hex.fromDec 293454837;
    expected = "117DC3F5";
  };

  testToHexString2 = {
    expr = self.hex.fromDec 4500;
    expected = "1194";
  };

  testToHexString3 = {
    expr = self.hex.fromDec 5942819;
    expected = "5AAE23";
  };

  testHexToDec = {
    expr = self.hex.toDec "FF";
    expected = 255;
  };

  testHexToDec2 = {
    expr = self.hex.toDec "333FAB333";
    expected = 13756969779;
  };

  testHexToDec3 = {
    expr = self.hex.toDec "0FF";
    expected = 255;
  };

  testHexToDec4 = {
    expr = self.hex.toDec "0000FF";
    expected = 255;
  };

  testHexToDec5 = {
    expr = self.hex.toDec "0A05";
    expected = 2565;
  };

  testCreateHexRange = {
    expr = self.hex.range 10 17;
    expected = [ "A" "B" "C" "D" "E" "F" "10" "11" ];
  };

  testCreateHexWithHigherStart = {
    expr = self.hex.range 49 17;
    expected = [ ];
  };

  testIsHexString = {
    expr = self.hex.isHexString "ABC";
    expected = true;
  };

  testIsHexStringWithInvalidHex = {
    expr = self.hex.isHexString "WHAT IS THIS";
    expected = false;
  };

  testHexPad = {
    expr = self.hex.pad 5 "A";
    expected = "0000A";
  };

  testHexPadWithLowerMaxDigits = {
    expr = self.hex.pad 1 "9AC";
    expected = "9AC";
  };

  testHexPadWithNegativeDigits = {
    expr = self.hex.pad (-5) "A42C";
    expected = "A42C";
  };
}
