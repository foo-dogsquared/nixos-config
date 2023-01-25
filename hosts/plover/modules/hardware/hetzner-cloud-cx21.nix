{ config, lib, pkgs, modulesPath, ... }:

# Most of the filesystems listed here are supposed to be overriden to default
# settings of whatever image format configuration this host system will import
# from nixos-generators.
let
  inherit (builtins) toString;
  inherit (import ./networks.nix) interfaces;

  # This is just referring to the same interface just with alternative names.
  mainEthernetInterfaceNames = [ "ens10" "enp0s10" ];
  internalEthernetInterfaceNames = [ "ens11" "enp0s11" ];
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "virtio_scsi" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems."/" = lib.mkOverride 2000 {
    label = "nixos";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/boot" = lib.mkOverride 2000 {
    label = "boot";
    fsType = "vfat";
  };

  zramSwap = {
    enable = true;
    numDevices = 1;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking = {
    enableIPv6 = true;
    usePredictableInterfaceNames = true;
    useNetworkd = true;

    # We're using networkd to configure so we're disabling this
    # service.
    useDHCP = false;
    dhcpcd.enable = false;
  };

  # The interface configuration is based from the following discussion:
  # https://discourse.nixos.org/t/nixos-on-hetzner-cloud-servers-ipv6/221/
  systemd.network = {
    enable = true;

    # For more information, you can look at Hetzner documentation from
    # https://docs.hetzner.com/robot/dedicated-server/ip/additional-ip-adresses/
    networks = {
      "20-wan" = {
        matchConfig.Name = lib.concatStringsSep " " mainEthernetInterfaceNames;

        # Setting the primary static IPs.
        address = with interfaces; [
          # The public IPs.
          "${main'.IPv4.address}/32"
          "${main'.IPv6.address}/128"
        ];

        networkConfig.IPForward = true;

        gateway = [
          interfaces.main'.IPv4.gateway
          interfaces.main'.IPv6.gateway
        ];

        routes = [
          { routeConfig.Gateway = interfaces.main'.IPv6.gateway; }
          { routeConfig.Destination = interfaces.main'.IPv4.address; }

          {
            routeConfig = {
              Gateway = interfaces.main'.IPv4.gateway;
              GatewayOnLink = true;
            };
          }
        ];
      };

      "20-lan" = with interfaces.internal; {
        matchConfig.Name = lib.concatStringsSep " " internalEthernetInterfaceNames;
        address = [
          "${IPv4.address}/16"
          "${IPv6.address}/64"
        ];
        gateway = [
          IPv4.gateway
          IPv6.gateway
        ];

        routes = [
          { routeConfig.Gateway = IPv6.gateway; }
          { routeConfig.Destination = IPv4.address; }

          {
            routeConfig = {
              Gateway = IPv4.gateway;
              GatewayOnLink = true;
            };
          }
        ];
      };

      "60-internal" = {
        matchConfig.Name = "ens*";
        networkConfig.DHCP = "yes";
      };
    };
  };

  # This is to look out for any errors that will occur for my networking setup
  # which is always a possibility.
  systemd.services.systemd-networkd.serviceConfig.Environment = "SYSTEMD_LOG_LEVEL=info";
}
