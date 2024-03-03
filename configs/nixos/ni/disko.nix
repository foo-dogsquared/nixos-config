{ disk ? "/dev/nvme0n1", config, lib, ... }:

{
  disko.devices = {
    disk.primary = {
      device = disk;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # You can't really have a btrfs-layered boot so this'll have to do.
          ESP = {
            priority = 1;
            start = "0";
            end = "512MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              mountpoint = "/boot";
              format = "vfat";
            };
          };

          swap = {
            start = "-8GiB";
            end = "-0";
            type = "8200";
            content = {
              type = "swap";
              randomEncryption = true;
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
                    mountOptions = [ "compress=zstd" "noatime" "noacl" ];
                    mountpoint = "/nix";
                  };
                }

                (lib.mkIf config.services.guix.enable {
                  "/gnu" = {
                    mountOptions = [ "compress=zstd" "noatime" "noacl" ];
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
