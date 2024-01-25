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
}
