{ self, lib, config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
    (lib.getUser "nixos" "nixos")
  ];

  networking.hostName = "graphical-installer";

  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  users.users.root.password = "";

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
    system = {
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
}
