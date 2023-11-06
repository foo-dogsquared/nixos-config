{ config, lib, pkgs, ... }:

{
  fileSystems."/".label = "root";
  fileSystems."/boot".label = "boot";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "23.05";
}
