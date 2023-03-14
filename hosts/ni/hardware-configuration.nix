{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./modules/hardware/traditional-networking.nix
  ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # The simpler WiFi manager.
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
        UseDefaultInterface = true;
        ControlPortOverNL80211 = true;
      };

      Network = {
        AutoConnect = true;
        NameResolvingService = "systemd";
      };
    };
  };

  # Set the NetworkManager backend to iwd for workflows that use it.
  networking.networkmanager.wifi.backend = "iwd";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    netbootxyz.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    label = "root";
    options = [
      "defaults"
      "noatime"
    ];
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    label = "boot";
    fsType = "vfat";
  };

  swapDevices = [{ label = "swap"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

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
}
