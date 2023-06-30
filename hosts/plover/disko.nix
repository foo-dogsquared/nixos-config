{ disks ? [ "/dev/sda" ], ... }:

{
  disk.sda = {
    device = builtins.elemAt disks 0;
    type = "disk";
    content = {
      format = "gpt";
      type = "table";
      partitions = [
        {
          name = "boot";
          start = "0";
          end = "1MiB";
          part-type = "primary";
          flags = [ "bios_grub" ];
        }

        {
          name = "ESP";
          start = "1MiB";
          end = "256MiB";
          bootable = true;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
          flags = [ "esp" ];
        }

        {
          name = "root";
          start = "256MiB";
          end = "100%";
          part-type = "primary";
          bootable = true;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        }
      ];
    };
  };
}
