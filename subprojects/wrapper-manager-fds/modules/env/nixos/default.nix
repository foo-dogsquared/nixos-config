{ config, lib, ... }:

let
  cfg = config.wrapper-manager;
in
{
  imports = [
    ../common.nix
  ];

  config = lib.mkMerge [
    { wrapper-manager.extraSpecialArgs.nixosConfig = config; }

    (lib.mkIf (cfg.wrappers != {}) {
      environment.systemPackages =
        lib.mapAttrsToList (_: wrapper: wrapper.build.toplevel) cfg.wrappers;
    })
  ];
}
