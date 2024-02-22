{ config, lib, ... }:

{
  disko.devices = {
    disk.primary = {
      device = [ "/dev/nvme0n1" ];
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # You can't really have a btrfs-layered boot so this'll have to do.
          ESP = {
            priority = 1;
            start = "0";
            end = "128MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              mountpoint = "/boot";
              format = "vfat";
            };
          };

          root = {
            size = "100%";
            type = "8300";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = lib.mkMerge [
                {
                  "/root" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/home";
                  };
                  "/nix" = {
                    mountOptions = [ "compress=zstd" "noatime" "noattr" "noacl" ];
                    mountpoint = "/nix";
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "8G";
                  };
                }

                (lib.mkIf config.services.guix.enable {
                  "/gnu" = {
                    mountOptions = [ "compress=zstd" "noatime" "noattr" "noacl" ];
                    mountpoint = "/gnu";
                  };
                })
              ];
            };
          };
        };
      };
    };
  };
}
