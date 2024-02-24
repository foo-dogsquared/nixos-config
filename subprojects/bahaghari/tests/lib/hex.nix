{ pkgs, lib }:

pkgs.lib.runTests {
  # Even though this is basically borrowing from nixpkgs', we still to test
  # them for consistency.
  testConvertToHex1 = {
    expr = lib.hex.toHexString 534;
    expected = "216";
  };

  testConvertToHex2 = {
    expr = lib.hex.toHexString 864954;
    expected = "D32BA";
  };

  testConvertToHex3 = {
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
}
