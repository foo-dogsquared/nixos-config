# A bunch of common hardware settings for desktop systems. Mostly, we're just
# adding drivers for common gaming peripherals.
{ lib, ... }:

{
  # Enable tablet support with OpenTabletDriver.
  hardware.opentabletdriver.enable = lib.mkDefault true;

  # Enable support for Bluetooth.
  hardware.bluetooth.enable = lib.mkDefault true;

  # Enable yer game controllers.
  hardware.steam-hardware.enable = lib.mkDefault true;
  hardware.xone.enable = lib.mkDefault true;
  hardware.xpadneo.enable = lib.mkDefault true;

  # This is useful for not interrupting your desktop activity. Also most of my
  # poor achy-breaky desktops can't take it.
  nix.daemonCPUSchedPolicy = "idle";
}
