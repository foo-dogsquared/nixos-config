{ pkgs ? import <nixpkgs> { }, utils ? import ../../utils.nix { inherit pkgs; } }:

let
  inherit (pkgs) lib;
  wrapperManager = import ../../../subprojects/wrapper-manager-fds { };
  wrapperManagerEval = module: args: wrapperManager.lib.build (args // {
    pkgs = args.pkgs or pkgs;
    modules = args.extraModules or [ ] ++ [
      module
      ../../../modules/wrapper-manager
      ../../../modules/wrapper-manager/_private
    ];
  });

  runTests = path: args:
    lib.mapAttrs (_: v: wrapperManagerEval v args) (import path);
in
{
  neovim = runTests ./programs/neovim { };
  bubblewrap = runTests ./sandboxing/bubblewrap { };
  boxxy = runTests ./sandboxing/boxxy { };
  zellij = runTests ./programs/zellij { };
  jujutsu = runTests ./programs/jujutsu { };
}
