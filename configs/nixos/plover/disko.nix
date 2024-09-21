{ disk ? "/dev/sda", ... }:

{
  disko.devices = {
    disk.primary = {
      device = disk;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            start = "0";
            end = "1MiB";
            type = "EF02";
          };

          # You can't really have a btrfs-layered boot so this'll have to do.
          ESP = {
            priority = 1;
            start = "1MiB";
            end = "256MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              mountpoint = "/boot";
              format = "vfat";
            };
          };

          root = {
            start = "256MiB";
            end = "100%";
            type = "8300";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = [
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
              ];
            };
          };
        };
      };
    };
  };
}
