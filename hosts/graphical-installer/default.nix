{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    (lib.getUser "nixos" "nixos")
  ];

  isoImage = {
    isoBaseName = config.networking.hostName;

    # Put the source code somewhere easy to see.
    contents = [{
      source = inputs.self;
      target = "/etc/nixos";
    }];
  };

  # We'll be using NetworkManager with the desktop environment anyways.
  networking.wireless.enable = false;

  # Use my desktop environment configuration without the apps just to make the
  # closure size smaller.
  workflows.workflows.a-happy-gnome = {
    enable = true;
    extraApps = [ ];
  };

  # Some niceties.
  profiles = {
    desktop.enable = true;
    dev.enable = true;
  };

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

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };

  users.users.root.password = "";

}
