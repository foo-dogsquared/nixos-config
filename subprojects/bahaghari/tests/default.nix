# This is the unit cases for our Nix project. It should only require a nixpkgs
# instance and we'll have to make it easy to test between the unstable and
# stable version of home-manager and NixOS.
{ branch ? "stable", system ? builtins.currentSystem }:

let
  sources = import ../npins;
  pkgs = import sources."nixos-${branch}" { inherit system; };
  bahaghariLib = import ./lib { inherit pkgs; };
in {
  lib = bahaghariLib;
  libTestPkg = pkgs.runCommand "bahaghari-lib-test" {
    testData = builtins.toJSON bahaghariLib;
    passAsFile = [ "testData" ];
    nativeBuildInputs = with pkgs; [ yajsv jq ];
  } ''
    yajsv -s "${
      ./lib/tests.schema.json
    }" "$testDataPath" && touch $out || jq . "$testDataPath"
  '';
  #modules = import ./modules { inherit pkgs; };
}
