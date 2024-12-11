{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
  hardware.xpadneo.enable = lib.mkForce false;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];

  services.ddccontrol.enable = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    netbootxyz.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
