let
  sources = import ../npins;
in
{
  pkgs ? import sources.nixos-unstable { },
}:

let
  wrapperManagerLibTests = import ./lib { inherit pkgs; };
  inherit (pkgs) lib;
in
{
  configs = let
    configs' = import ./configs { inherit pkgs; };
    updateTestName = configName: package: lib.mapAttrs' (n: v: lib.nameValuePair "${configName}-${n}" v) package.wrapperManagerTests;
  in
    lib.concatMapAttrs updateTestName configs';

  lib =
    pkgs.runCommand "wrapper-manager-fds-lib-test"
      {
        testData = builtins.toJSON wrapperManagerLibTests;
        passAsFile = [ "testData" ];
        nativeBuildInputs = with pkgs; [
          yajsv
          jq
        ];
      }
      ''
        yajsv -s "${./lib/tests.schema.json}" "$testDataPath" && touch $out || jq . "$testDataPath"
      '';
}
