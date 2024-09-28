{ ... }:

{
  disko.devices = {
    disk.disk1 = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            priority = 1;
            size = "1M";
            type = "EF02";
          };

          ESP = {
            size = "500M";
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

              subvolumes = {
                "/root" = {
                  mountOptions = [ "compress=zstd:10" ];
                  mountpoint = "/";
                };
                "/home" = {
                  mountOptions = [ "compress=zstd:10" ];
                  mountpoint = "/home";
                };
                "/nix" = {
                  mountOptions = [ "compress=zstd:8" "noatime" "noacl" ];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
  };
}
