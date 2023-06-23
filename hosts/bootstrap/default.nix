{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    (lib.getUser "nixos" "nixos")
  ];

  isoImage = {
    isoBaseName = config.networking.hostName;
    contents = [{
      source = inputs.self;
      target = "/bootstrap/";
    }];
    storeContents = [
      inputs.self.devShells.${config.nixpkgs.system}.default
    ] ++ builtins.attrValues inputs;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };

  users.users.root.password = "";
}
