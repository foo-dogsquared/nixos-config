{ lib, config, pkgs, modulesPath, ... }:

# Since this will be exported as an installer ISO, you'll have to keep in mind
# about the added imports from nixos-generators. In this case, it simply adds
# the NixOS installation CD profile.
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  isoImage = {
    isoBaseName = config.networking.hostName;

    # Put the source code somewhere easy to see.
    contents = [{
      source = ../..;
      target = "/etc/nixos";
    }];

    squashfsCompression = "zstd -Xcompression-level 10";
  };

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Use my desktop environment configuration without the apps just to make the
  # closure size smaller.
  workflows.workflows.a-happy-gnome = {
    enable = true;
    extraApps = [ ];
  };

  # Some niceties.
  profiles.desktop.enable = true;

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

  system.stateVersion = "23.11";
}
