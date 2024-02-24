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
      pkgs.lib.importJSON dataDrv.outPath;

  /* Convert a given decimal number to a specified base digit with the set of
     glyphs for each digit as returned from lib.toBaseDigits.

     Type: toBaseDigitWithGlyphs :: Int -> Int -> Attrs -> String

     Example:
       toBaseDigitWithGlyphs 24 267 {
          "0" = "0";
          # ...
          "22" = "L";
          "23" = "M";
          "24" = "N";
        }
  */
  toBaseDigitsWithGlyphs = base: i: glyphs:
    let
      baseDigits = pkgs.lib.toBaseDigits base i;
      toBaseDigits = d: glyphs.${builtins.toString d};
    in
    pkgs.lib.concatMapStrings toBaseDigits baseDigits;
}
