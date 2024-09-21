# An extended version of the headless profile from nixpkgs. We're only covering
# the most basic settings here. This will be used both for desktop and server
# systems.
{ lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/headless.nix"
  ];

  # Sounds? We don't need in this void world of OURS!
  sound.enable = lib.mkDefault false;

  # Bluetooth is so 2000s, my wireless earbuds are scratching all to hell.
  hardware.bluetooth.enable = lib.mkDefault false;

  # You can draw from your imagination instead.
  hardware.opentabletdriver.enable = lib.mkDefault false;

  # Printers? In our godforsaken headless setups. (Ok there are servers that
  # handle this but you know...)
  services.printing.enable = lib.mkDefault false;
}
