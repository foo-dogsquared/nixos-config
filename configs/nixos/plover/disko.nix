{ config, lib, ... }:

{
  disko.devices = {
    disk.sda = {
      device = [ "/dev/sda" ];
      type = "disk";
      content = {
        type = "gpt";
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
  };
}
