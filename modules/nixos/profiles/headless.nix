# An extended version of the headless profile from nixpkgs. We're only covering
# the most basic settings here. This will be used both for desktop and server
# systems.
{ lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/headless.nix"
  ];

  # So does sounds...
  sound.enable = lib.mkDefault false;

  # ...and Bluetooth because it's so insecure.
  hardware.bluetooth.enable = lib.mkDefault false;

  # And other devices...
  hardware.opentabletdriver.enable = lib.mkDefault false;
  services.printing.enable = lib.mkDefault false;
}
