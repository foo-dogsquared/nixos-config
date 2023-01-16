{ config, lib, pkgs, modulesPath, ... }:

# Most of the filesystems listed here are supposed to be overriden to default
# settings of whatever image format configuration this host system will import
# from nixos-generators.
let
  network = import ./networks.nix;
  inherit (network) publicIP publicIPv6 privateNetworkGatewayIP;
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
    useDHCP = false;
    useNetworkd = true;

    # We're using networkd to configure so we're disabling this
    # service.
    dhcpcd.enable = false;
  };

  # The interface configuration is based from the following discussion:
  # https://discourse.nixos.org/t/nixos-on-hetzner-cloud-servers-ipv6/221/
  systemd.network = {
    enable = true;
    networks."20-wan" = {
      matchConfig.Name = "ens3";

      address = [
        # Public IPs.
        publicIP
        "${publicIPv6}1/64"

        # The private network IP.
        "172.23.0.1/32"

        # Randomly generate from the IPv6 range.
        "::"
      ];

      routes = [
        # Configuring the route with the gateway addresses for this network.
        { routeConfig.Gateway = "fe80::1"; }
        { routeConfig.Destination = privateNetworkGatewayIP; }
        { routeConfig = { Gateway = privateNetworkGatewayIP; GatewayOnLink = true; }; }

        # Private addresses.
        { routeConfig = { Destination = "172.16.0.0/12"; Type = "unreachable"; }; }
        { routeConfig = { Destination = "192.168.0.0/16"; Type = "unreachable"; }; }
        { routeConfig = { Destination = "10.0.0.0/8"; Type = "unreachable"; }; }
        { routeConfig = { Destination = "fc00::/7"; Type = "unreachable"; }; }
      ];
    };
  };

  # This is to look out for any errors that will occur for my networking setup
  # which is always a possibility.
  systemd.services.systemd-networkd.serviceConfig.Environment = "SYSTEMD_LOG_LEVEL=debug";
}
