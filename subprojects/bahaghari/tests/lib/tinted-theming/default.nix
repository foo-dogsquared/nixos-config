{ pkgs, lib, self }:

let
  sampleBase16Scheme = self.tinted-theming.importScheme ./sample-base16-scheme.yml;
  sampleBase16Scheme' = self.tinted-theming.importScheme ./sample-base16-scheme-with-missing-colors.yml;
  sampleBase24Scheme = self.tinted-theming.importScheme ./sample-base24-scheme.yml;
  sampleBase24Scheme' = self.tinted-theming.importScheme ./sample-base24-scheme-with-missing-colors.yml;
in
lib.runTests {
  testTintedThemingSchemeImport = {
    expr = self.tinted-theming.importScheme ./sample-base16-scheme.yml;
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

  testTintedThemingLegacyBase24SchemeImport = {
    expr = self.tinted-theming.importScheme ./sample-legacy-base24.yml;
    expected = {
      system = "base24";
      name = "Scheme Name";
      author = "Scheme Author";
      description = "a short description of the scheme";
      palette = {
        base00 = "000000";
        base01 = "111111";
        base02 = "222222";
        base03 = "333333";
        base04 = "444444";
        base05 = "555555";
        base06 = "666666";
        base07 = "777777";
        base08 = "888888";
        base09 = "999999";
        base0A = "aaaaaa";
        base0B = "bbbbbb";
        base0C = "cccccc";
        base0D = "dddddd";
        base0E = "eeeeee";
        base0F = "ffffff";
        base10 = "000000";
        base11 = "111111";
        base12 = "222222";
        base13 = "333333";
        base14 = "444444";
        base15 = "555555";
        base16 = "666666";
        base17 = "777777";
      };
    };
  };

  testTintedThemingLegacyBase16SchemeImport = {
    expr = self.tinted-theming.importScheme ./sample-legacy-base16.yml;
    expected = {
      system = "base16";
      name = "Scheme Name";
      author = "Scheme Author";
      description = "a short description of the scheme";
      palette = {
        base00 = "000000";
        base01 = "111111";
        base02 = "222222";
        base03 = "333333";
        base04 = "444444";
        base05 = "555555";
        base06 = "666666";
        base07 = "777777";
        base08 = "888888";
        base09 = "999999";
        base0A = "aaaaaa";
        base0B = "bbbbbb";
        base0C = "cccccc";
        base0D = "dddddd";
        base0E = "eeeeee";
        base0F = "ffffff";
      };
    };
  };

  testIsBase16 = {
    expr = self.tinted-theming.isBase16 sampleBase16Scheme.palette;
    expected = true;
  };

  testIsNotBase16 = {
    expr = self.tinted-theming.isBase16 sampleBase16Scheme'.palette;
    expected = false;
  };

  testIsBase24 = {
    expr = self.tinted-theming.isBase24 sampleBase24Scheme.palette;
    expected = true;
  };

  testIsNotBase24 = {
    expr = self.tinted-theming.isBase24 sampleBase24Scheme'.palette;
    expected = false;
  };

  testIsALegacyBase16Scheme = {
    expr = self.tinted-theming.isLegacyScheme (self.importYAML ./sample-legacy-base16.yml);
    expected = true;
  };

  testIsALegacyBase24Scheme = {
    expr = self.tinted-theming.isLegacyScheme (self.importYAML ./sample-legacy-base24.yml);
    expected = true;
  };
}
