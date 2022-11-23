{ lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/srv" = {
    label = "data";
    options = [
      "discard"
      "defaults"
    ];
    fsType = "ext4";
  };
}
