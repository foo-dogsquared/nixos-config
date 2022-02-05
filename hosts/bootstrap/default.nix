{ self, lib, config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    (lib.getUser "nixos" "nixos")
  ];

  isoImage = {
    isoBaseName = "bootstrap-${config.networking.hostName}";
    contents = [{
      source = self;
      target = "/bootstrap/";
    }];
    storeContents = [
      self.devShell.${config.nixpkgs.system}
    ] ++ builtins.attrValues inputs;
  };

  networking.hostName = "bootstrap";
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  users.users.root.password = "";

  boot.loader.systemd-boot.enable = true;
}
