# Some quality-of-life features for your hardware.
{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.hardware.qol;
in {
  options.hosts.ni.hardware.qol.enable =
    lib.mkEnableOption "quality-of-life hardware features";

  config = lib.mkIf cfg.enable {
    # Bring in some of them good tools.
    suites.filesystem.tools.enable = true;

    # Set up printers.
    services.printing = {
      enable = true;
      browsing = true;
      drivers = with pkgs; [ gutenprint splix ];
    };

    # Extend the life of an SSD.
    services.fstrim.enable = true;
  };
}
