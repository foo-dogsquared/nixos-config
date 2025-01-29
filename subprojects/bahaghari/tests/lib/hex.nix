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

  testHexToDecLowercase = {
    expr = self.hex.toDec "0A0FfbA";
    expected = 10551226;
  };

  testHexToDecLowercase2 = {
    expr = self.hex.toDec "0af";
    expected = 175;
  };

  testCreateHexRange = {
    expr = self.hex.range 10 17;
    expected = [ "A" "B" "C" "D" "E" "F" "10" "11" ];
  };

  testCreateHexRange2 = {
    expr = self.hex.range 64 76;
    expected =
      [ "40" "41" "42" "43" "44" "45" "46" "47" "48" "49" "4A" "4B" "4C" ];
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

  testHexPadWithMixedLetterCase = {
    expr = self.hex.pad 8 "AfB9";
    expected = "0000AfB9";
  };
}
