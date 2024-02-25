{ pkgs, lib }:

{
  inherit (pkgs.lib.generators) toYAML;

  /* Read YAML files into a Nix expression similar to lib.importJSON and
     lib.importTOML from nixpkgs standard library. Unlike both of them, this
     unfortunately relies on an import-from-derivation (IFD) so it isn't exactly
     perfect but it is very close.

     This relies on yaml2json which uses the following YAML library which you
     can view the following link for more details on YAML compatibility.

     https://pkg.go.dev/gopkg.in/yaml.v3#readme-compatibility

     Type: importYAML :: Path -> any

     Example:
       importYAML ./simple.yml
  */
  importYAML = path:
    let
      dataDrv = pkgs.runCommand "convert-yaml-to-json" { } ''
        ${pkgs.lib.getExe' pkgs.yaml2json "yaml2json"} < "${path}" > "$out"
      '';
    in
    pkgs.lib.importJSON dataDrv;

  /* Convert a given decimal number to a specified base digit with the set of
     glyphs for each digit as returned from lib.toBaseDigits.

     Type: toBaseDigitWithGlyphs :: Int -> Int -> Attrs -> String

     Example:
       toBaseDigitWithGlyphs 24 267 {
          "0" = "0";
          "1" = "1";
          "2" = "2";
          # ...
          "22" = "O";
          "23" = "P";
        }
      =>
  */
  toBaseDigitsWithGlyphs = base: i: glyphs:
    let
      baseDigits = pkgs.lib.toBaseDigits base i;
      toBaseDigits = d: glyphs.${builtins.toString d};
    in
    pkgs.lib.concatMapStrings toBaseDigits baseDigits;

  /* Generates a glyph set usable for `toBaseDigitsWithGlyphs`. Take note the
     given list is assumed to be sorted and the generated glyph set starts at
     `0` up to (`listLength - 1`).

     Type: generateGlyphSet :: [ String ] -> Attrs

     Example:
       generateGlyphSet [ "0" "1" "2" "3" "4" "5" "6" "7" "8 "9" "A" "B" "C" "D" "E" "F" ]
       => {
         "0" = "0";
         "1" = "1";
         # ...
         "14" = "E";
         "15" = "F";
       }
  */
  generateGlyphSet = glyphsList:
    let
      glyphsList' =
        pkgs.lib.lists.imap0
          (i: glyph: { "${builtins.toString i}" = glyph; })
          glyphsList;
    in
    pkgs.lib.foldl (acc: glyph: acc // glyph) { } glyphsList';
}
