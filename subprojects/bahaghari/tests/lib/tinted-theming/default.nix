{ pkgs, lib }:

let
  sampleBase16Scheme = lib.trivial.importYAML ./sample-base16-scheme.yml;
  sampleBase16Scheme' = lib.trivial.importYAML ./sample-base16-scheme-with-missing-colors.yml;
  sampleBase24Scheme = lib.trivial.importYAML ./sample-base24-scheme.yml;
  sampleBase24Scheme' = lib.trivial.importYAML ./sample-base24-scheme-with-missing-colors.yml;
in
pkgs.lib.runTests {
  testIsBase16 = {
    expr = lib.tinted-theming.isBase16 sampleBase16Scheme.palette;
    expected = true;
  };

  testIsNotBase16 = {
    expr = lib.tinted-theming.isBase16 sampleBase16Scheme'.palette;
    expected = false;
  };

  testIsBase24 = {
    expr = lib.tinted-theming.isBase24 sampleBase24Scheme.palette;
    expected = true;
  };

  testIsNotBase24 = {
    expr = lib.tinted-theming.isBase24 sampleBase24Scheme'.palette;
    expected = false;
  };
}
