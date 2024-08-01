let
  sources = import ../npins;
in
{
  pkgs ? import sources.nixos-unstable { },
}:

let
  lib = import ./lib { inherit pkgs; };
in
{
  inherit lib;
  libTestPkg =
    pkgs.runCommand "wrapper-manager-fds-lib-test"
      {
        testData = builtins.toJSON lib;
        passAsFile = [ "testData" ];
        nativeBuildInputs = with pkgs; [
          yajsv
          jq
        ];
      }
      ''
        yajsv -s "${./lib/tests.schema.json}" "$testDataPath" && touch $out || jq . "$testDataPath"
      '';
  configs = import ./configs { inherit pkgs; };
}
