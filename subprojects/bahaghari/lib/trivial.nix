{ pkgs, lib }:

{
  /* Read YAML files into a Nix expression similar to lib.importJSON and
     lib.importTOML from nixpkgs standard library. Unlike both of them, this
     unfortunately relies on an import-from-derivation (IFD) so it isn't exactly
     perfect but it is very close.

     This relies on yaml2json which uses the following YAML library which you
     can view the following link for more details on YAML compatibility.

     https://pkg.go.dev/gopkg.in/yaml.v3#readme-compatibility

     Type: importYAML :: path -> any
  */
  importYAML = path:
    let
      data = pkgs.runCommand "convert-yaml-to-json" { } ''
        ${pkgs.lib.getExe' pkgs.yaml2json "yaml2json"} < ${path} > $out
      '';
    in
      pkgs.lib.importJSON data;
}
