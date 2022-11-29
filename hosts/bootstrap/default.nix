{ self, lib, config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    (lib.getUser "nixos" "nixos")
  ];

  isoImage = {
    isoBaseName = "bootstrap";
    contents = [{
      source = self;
      target = "/bootstrap/";
    }];
    storeContents = [
      self.devShells.${config.nixpkgs.system}.default
    ] ++ builtins.attrValues inputs;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };

  networking.hostName = "bootstrap";

  users.users.root.password = "";
}
