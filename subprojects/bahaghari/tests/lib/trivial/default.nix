{ pkgs, lib, self }:

let
  # The typical rounding procedure for our results. 10 decimal places should be
  # enough to test accuracy at least for a basic math subset like this.
  round' = self.math.round' (-6);

  customOctalGlyphs = {
    "0" = "A";
    "1" = "B";
    "2" = "C";
    "3" = "D";
    "4" = "E";
    "5" = "F";
    "6" = "G";
    "7" = "H";
  };

  base24GlyphsList = [
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
    "G"
    "H"
    "I"
    "J"
    "K"
    "L"
    "M"
    "N"
  ];

  customBase24Glyphs = {
    "0" = "0";
    "1" = "1";
    "2" = "2";
    "3" = "3";
    "4" = "4";
    "5" = "5";
    "6" = "6";
    "7" = "7";
    "8" = "8";
    "9" = "9";
    "10" = "A";
    "11" = "B";
    "12" = "C";
    "13" = "D";
    "14" = "E";
    "15" = "F";
    "16" = "G";
    "17" = "H";
    "18" = "I";
    "19" = "J";
    "20" = "K";
    "21" = "L";
    "22" = "M";
    "23" = "N";
  };

  base24Set = self.trivial.generateBaseDigitType base24GlyphsList;
in
lib.runTests {
  testGenerateCustomGlyphSet = {
    expr = self.trivial.generateGlyphSet [ "A" "B" "C" "D" "E" "F" "G" "H" ];
    expected = customOctalGlyphs;
  };

  testGenerateBase24GlyphSet = {
    expr = self.trivial.generateGlyphSet base24GlyphsList;
    expected = customBase24Glyphs;
  };

  testGenerateConversionTable = {
    expr = self.trivial.generateConversionTable [ "A" "B" "C" "D" "E" "F" "G" "H" ];
    expected = {
      "A" = 0;
      "B" = 1;
      "C" = 2;
      "D" = 3;
      "E" = 4;
      "F" = 5;
      "G" = 6;
      "H" = 7;
    };
  };

  testGenerateConversionTable2 = {
    expr = self.trivial.generateConversionTable
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
    expected = {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "A" = 10;
      "B" = 11;
      "C" = 12;
      "D" = 13;
      "E" = 14;
      "F" = 15;
    };
  };

  # Testing out the custom factory methods if they are working as intended.
  testCustomBaseDigitSetToDec = {
    expr = base24Set.toDec "12H";
    expected = 641;
  };

  testCustomBaseDigitSetFromDec = {
    expr = base24Set.fromDec 641;
    expected = "12H";
  };

  testBaseDigitWithCustomOctalGlyph = {
    expr = self.trivial.toBaseDigitsWithGlyphs 8 9 customOctalGlyphs;
    expected = "BB";
  };

  testBaseDigitWithCustomOctalGlyph2 = {
    expr = self.trivial.toBaseDigitsWithGlyphs 8 641 customOctalGlyphs;
    expected = "BCAB";
  };

  testBaseDigitWithProperBase24Glyph = {
    expr = self.trivial.toBaseDigitsWithGlyphs 24 641 customBase24Glyphs;
    expected = "12H";
  };

  testBaseDigitWithProperBase24Glyph2 = {
    expr = self.trivial.toBaseDigitsWithGlyphs 24 2583 customBase24Glyphs;
    expected = "4BF";
  };

  # We're mainly testing if the underlying YAML selfrary is mostly compliant
  # with whatever it claims.
  testImportBasicYAML = {
    expr = self.trivial.importYAML ./simple.yml;
    expected = {
      hello = "there";
      how-are-you-doing = "I'm fine. Thank you for asking.\n";
      "It's a number" = 53;
      dog-breeds = [ "chihuahua" "golden retriever" ];
    };
  };

  testImportTintedThemingBase16YAML = {
    expr = self.trivial.importYAML ../tinted-theming/sample-base16-scheme.yml;
    expected = {
      system = "base16";
      name = "Bark on a tree";
      author = "Gabriel Arazas (https://foodogsquared.one)";
      description = "Rusty theme resembling forestry inspired from Nord theme.";
      variant = "dark";
      palette = {
        base00 = "2b221f";
        base01 = "412c26";
        base02 = "5c362c";
        base03 = "a45b43";
        base04 = "e1bcb2";
        base05 = "f5ecea";
        base06 = "fefefe";
        base07 = "eb8a65";
        base08 = "d03e68";
        base09 = "df937a";
        base0A = "afa644";
        base0B = "85b26e";
        base0C = "eb914a";
        base0D = "c67f62";
        base0E = "8b7ab9";
        base0F = "7f3F83";
      };
    };
  };

  # YAML is a superset of JSON (or was it the other way around?) after v1.2.
  testToYAML = {
    expr = self.trivial.toYAML { } { hello = "there"; };
    expected = "{\"hello\":\"there\"}";
  };

  testNumberClamp = {
    expr = self.trivial.clamp 1 10 4;
    expected = 4;
  };

  testNumberClampMin = {
    expr = self.trivial.clamp 1 10 (-5);
    expected = 1;
  };

  testNumberClampMax = {
    expr = self.trivial.clamp 1 10 453;
    expected = 10;
  };

  testNumberScale = {
    expr = self.trivial.scale { inMin = 0; inMax = 15; outMin = 0; outMax = 255; } 15;
    expected = 255;
  };

  testNumberScale2 = {
    expr = self.trivial.scale { inMin = 0; inMax = 15; outMin = 0; outMax = 255; } 4;
    expected = 68;
  };

  testNumberScale3 = {
    expr = self.trivial.scale { inMin = 0; inMax = 15; outMin = 0; outMax = 255; } (-4);
    expected = (-68);
  };

  testNumberScaleFloat = {
    expr = self.trivial.scale { inMin = 0; inMax = 255; outMin = 0.0; outMax = 1.0; } 255;
    expected = 1.0;
  };

  testNumberScaleFloat2 = {
    expr = self.trivial.scale { inMin = 0; inMax = 255; outMin = 0.0; outMax = 1.0; } 127.5;
    expected = 0.5;
  };

  testNumberScaleFloat3 = {
    expr = round' (self.trivial.scale { inMin = 0; inMax = 255; outMin = 0.0; outMax = 1.0; } 53);
    expected = round' 0.207843;
  };

  testIsNumber1 = {
    expr = self.trivial.isNumber 3;
    expected = true;
  };

  testIsNumber2 = {
    expr = self.trivial.isNumber 4.09;
    expected = true;
  };

  testIsNumber3 = {
    expr = self.trivial.isNumber "HELLO";
    expected = false;
  };

  testIsNumber4 = {
    expr = self.trivial.isNumber true;
    expected = false;
  };

  testOptionalNull = {
    expr = self.trivial.optionalNull true "HELLO";
    expected = "HELLO";
  };

  testOptionalNull2 = {
    expr = self.trivial.optionalNull false "HELLO";
    expected = null;
  };

  testToFloat = {
    expr = self.trivial.toFloat 46;
    expected = 46.0;
  };

  testToFloat2 = {
    expr = self.trivial.toFloat 26.5;
    expected = 26.5;
  };
}
