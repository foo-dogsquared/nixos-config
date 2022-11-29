{ self, lib, config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
    (lib.getUser "nixos" "nixos")
  ];

  isoImage = {
    isoBaseName = config.networking.hostName;
    contents = [{
      source = self;
      target = "/bootstrap/";
    }];
    storeContents = [
      self.devShell.${config.nixpkgs.system}
    ] ++ builtins.attrValues inputs;
  };

  profiles = {
    desktop = {
      enable = true;
      fonts.enable = true;
    };
    dev = {
      enable = true;
      shell.enable = true;
      neovim.enable = true;
    };
  };

  workflows.workflows.a-happy-gnome.enable = true;
  services.xserver.displayManager = {
    gdm = {
      enable = true;
      autoSuspend = false;
    };
    autoLogin = {
      enable = true;
      user = "nixos";
    };
  };

  networking.hostName = "graphical-installer";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };

  users.users.root.password = "";

}
