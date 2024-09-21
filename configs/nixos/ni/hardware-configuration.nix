{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    netbootxyz.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.services.udev.rules = ''
    KERNELS=="input0", SUBSYSTEMS=="input", ATTRS{id/product}=="0001", ATTRS{id/vendor}=="0001", ATTRS{id/version}=="ab83", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  services.udev.extraRules = ''
    KERNELS=="input0", SUBSYSTEMS=="input", ATTRS{id/product}=="0001", ATTRS{id/vendor}=="0001", ATTRS{id/version}=="ab83", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';
}
