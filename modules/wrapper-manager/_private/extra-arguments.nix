{ pkgs, lib, ... }:

let foodogsquaredLib = import ../../../lib { inherit pkgs; };
in {
  _module.args.foodogsquaredLib = foodogsquaredLib.extend (final: prev: {
    wrapper-manager = import ../../../lib/env-specific/wrapper-manager.nix {
      inherit pkgs lib;
      self = final;
    };
  });
}
