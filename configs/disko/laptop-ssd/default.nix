{ disk ? "/dev/nvme1n1", prefix ? "ni", ... }:

{
  disko.devices = {
    disk."${prefix}-secondary" = {
      device = disk;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          data = {
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
              };
            };
          };
        };
      };
    };
  };
}
