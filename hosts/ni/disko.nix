{ disks ? [ "/dev/nvme0n1" ], ... }:

{
  disk.nvme0n1 = {
    device = builtins.elemAt disks 0;
    type = "disk";
    content = {
      format = "gpt";
      type = "table";
      partitions = [
        {
          name = "root";
          start = "512MiB";
          end = "-8GiB";
          part-type = "primary";
          content = {
            type = "filesystem";
            mountpoint = "/";
            format = "ext4";
          };
        }

        {
          name = "ESP";
          start = "0";
          end = "512MiB";
          bootable = true;
          content = {
            type = "filesystem";
            mountpoint = "/boot";
            format = "vfat";
          };
        }

        {
          name = "swap";
          start = "-8GiB";
          end = "100%";
          part-type = "primary";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        }
      ];
    };
  };
}
