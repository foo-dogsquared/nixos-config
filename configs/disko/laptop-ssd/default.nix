{ disk ? "/dev/nvme1n1", ... }:

{
  disko.devices = {
    disk."ni-secondary" = {
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
                  mountOptions = [
                    "rw"
                    "user"
                    "noauto"
                    "nofail"
                    "compress=zstd:10"
                  ];
                  mountpoint = "/media/laptop-ssd";
                };
              };
            };
          };
        };
      };
    };
  };
}
