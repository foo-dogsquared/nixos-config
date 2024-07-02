{ config, lib, ... }:

let
  cfg = config.wrapper-manager;
in
{
  imports = [
    ../common.nix
  ];

  options.wrapper-manager.wrappers = lib.mkOption {
    type = lib.types.submoduleWith {
      specialArgs.nixosConfig = config;
    };
  };

  config = lib.mkIf (cfg.wrappers != {}) {
    environment.systemPackages =
      lib.mapAttrsToList (_: wrapper: wrapper.config.build.toplevel) cfg.wrappers;
  };
}
