{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    (lib.getUser "nixos" "nixos")
  ];

  isoImage = {
    isoBaseName = config.networking.hostName;

    # Store the source code in a easy-to-locate path.
    contents = [{
      source = inputs.self;
      target = "/etc/nixos/";
    }];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };

  # Assume that this will be used for remote installations.
  services.openssh = {
    enable = true;
    allowSFTP = true;
  };

  users.users.root.password = "";
}
