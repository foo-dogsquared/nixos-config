{ config, lib, pkgs, modulesPath, ... }:

# Most of the filesystems listed here are supposed to be overriden to default
# settings of whatever image format configuration this host system will import
# from nixos-generators.
let
  network = import ./networks.nix;
  inherit (builtins) toString;
  inherit (network) publicIP' publicIPv6 publicIPv6PrefixLength privateNetworkGatewayIP;

  # This is just referring to the same interface just with alternative names.
  mainEthernetInterfaceNames = [ "ens3" "enp0s3" ];
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
      "60-wan" = {
        matchConfig.Name = lib.concatStringsSep " " mainEthernetInterfaceNames;

        # Setting the primary static IPs.
        address = [
          publicIP'

          # The public IPv6 is assigned to a server so we'll to have to go with
          # something else.
          "${publicIPv6}2/${toString publicIPv6PrefixLength}"
        ];

        networkConfig = {
          DHCP = "yes";
          IPForward = true;
          IPMasquerade = "both";
        };

        routes = [
          { routeConfig.Gateway = "fe80::1"; }
          { routeConfig.Destination = publicIP'; }

          {
            routeConfig = {
              Gateway = publicIP';
              GatewayOnLink = true;
            };
          }
        ];
      };

      # This is to make use of the remaining ethernet interfaces as we can
      # build a local network.
      "60-dhcpv6-pd-downstreams" = {
        matchConfig.Name = "en*";
        networkConfig.DHCP = "yes";
      };
    };
  };

  # This is to look out for any errors that will occur for my networking setup
  # which is always a possibility.
  systemd.services.systemd-networkd.serviceConfig.Environment = "SYSTEMD_LOG_LEVEL=debug";
}
