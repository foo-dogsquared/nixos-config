# A simple external HDD filesystem primarily used as a persistent live
# installer. We're using btrfs since we don't have any significant work with
# other systems for now so we can afford to do this.
{ disk ? "/dev/sda", ... }:

{
  disko.devices = {
    disk.live-installer = {
      device = disk;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # You can't really have a btrfs-layered boot so this'll have to do.
          ESP = {
            priority = 1;
            start = "0";
            end = "256MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              mountpoint = "/boot";
              format = "vfat";
            };
          };

          # Just a tiny swap partition. This should have a remaining budget of
          # (X - 7GB) for our custom data. To allows us to have a buffer which
          # is especially useful for our potato laptop.
          swap = {
            start = "-6GiB";
            end = "-0";
            type = "8200";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };

          # The end-all-be-all partition. Contains the treasure trove of data.
          # Be mindful!
          root = {
            size = "100%";
            type = "8300";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = {
                "/root" = {
                  mountOptions = [ "compress=zstd:6" ];
                  mountpoint = "/";
                };
                "/home".mountpoint = "/home";
                "/nix" = {
                  mountOptions = [ "compress=zstd:6" "noatime" "noacl" ];
                  mountpoint = "/nix";
                };

                # Where the data where will be stored.
                "/data".mountpoint = "/data";
              };
            };
          };
        };
      };
    };
  };
}
