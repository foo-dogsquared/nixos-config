{ config, lib, ... }:

let
  cfg = config.wrapper-manager;
in
{
  imports = [
    ../common.nix
  ];

  config = lib.mkMerge [
    { wrapper-manager.extraSpecialArgs.hmConfig = config; }

    (lib.mkIf (cfg.packages != {}) {
      home.packages =
        lib.mapAttrsToList (_: wrapper: wrapper.build.toplevel) cfg.packages;
    })
  ] ;
}
