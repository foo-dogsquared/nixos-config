{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

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

  networking = {
    useDHCP = false;
    usePredictableInterfaceNames = true;
    useNetworkd = true;

    # We're using networkd to configure so we're disabling this
    # service.
    dhcpcd.enable = false;
  };

  # Enable systemd-resolved. This is mostly setup by `systemd.network.enable`
  # by we're being explicit just to be safe.
  services.resolved = {
    enable = true;
    llmnr = "true";
  };

  # Combining my ethernet and wireless network interfaces.
  systemd.network = {
    enable = true;
    netdevs."40-bond1" = {
      netdevConfig = {
        Name = "bond1";
        Kind = "bond";
      };
    };

    networks = {
      "40-bond1" = {
        matchConfig.Name = "bond1";
        networkConfig.DHCP = "yes";
      };

      "40-bond1-dev1" = {
        matchConfig.Name = "enp1s0";
        networkConfig.Bond = "bond1";
      };

      "40-bond1-dev2" = {
        matchConfig.Name = "wlp2s0";
        networkConfig.Bond = "bond1";
      };
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}
