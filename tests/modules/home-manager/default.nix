# We're basically reimplmenting parts from the home-manager test suite here
# just with our own modules included.
{ pkgs ? import <nixpkgs> { }
, homeManagerSrc ? <home-manager>
, enableBig ? true
}:

let
  nmt = pkgs.nix-lib-nmt;
  lib = import "${homeManagerSrc}/modules/lib/stdlib-extended.nix" pkgs.lib;
  homeManagerModules = import "${homeManagerSrc}/modules/modules.nix" {
    inherit pkgs lib;
    check = false;
  };
  modules = homeManagerModules ++ [
    ../../../modules/home-manager
    ../../../modules/home-manager/_private

    # Copied over from home-manager test suite.
    {
      # Bypass <nixpkgs> reference inside modules/modules.nix to make the test
      # suite more pure.
      _module.args.pkgsPath = pkgs.path;

      # Fix impurities. Without these some of the user's environment
      # will leak into the tests through `builtins.getEnv`.
      xdg.enable = true;
      home = {
        username = "hm-user";
        homeDirectory = "/home/hm-user";
        stateVersion = lib.mkDefault "18.09";
      };

      # Avoid including documentation since this will cause
      # unnecessary rebuilds of the tests.
      manual.manpages.enable = lib.mkDefault false;

      imports = [
        "${homeManagerSrc}/tests/asserts.nix"
        "${homeManagerSrc}/tests/big-test.nix"
        "${homeManagerSrc}/tests/stubs.nix"
      ];

      test.enableBig = enableBig;
    }
  ];

  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
import nmt {
  inherit pkgs lib modules;
  testedAttrPath = [ "home" "activationPackage" ];
  tests = builtins.foldl' (a: b: a // (import b)) { } ([
    ./programs/neovide
    ./programs/pipewire
    ./programs/pop-launcher
  ]
  ++ lib.optionals isLinux [
    ./services/archivebox
    ./services/gallery-dl
    ./services/matcha
    ./services/plover
    ./services/yt-dlp
  ]);
}
