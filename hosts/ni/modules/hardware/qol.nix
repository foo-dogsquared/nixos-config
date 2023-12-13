# Some quality-of-life features for your hardware.
{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.hardware.qol;
in
{
  options.hosts.ni.hardware.qol.enable = lib.mkEnableOption "quality-of-life hardware features";

  config = lib.mkIf cfg.enable {
    # Bring in some of them good tools.
    profiles.filesystem.tools.enable = true;

    # We're using some better filesystems so we're using it.
    boot.initrd.supportedFilesystems = [ "btrfs" ];
    boot.supportedFilesystems = [ "btrfs" ];

    # Set up printers.
    services.printing = {
      enable = true;
      browsing = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        splix
      ];
    };

    # Make your CPU more useful.
    services.auto-cpufreq.enable = true;

    # Extend the life of an SSD.
    services.fstrim.enable = true;
  };
}
