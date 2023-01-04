{ lib, pkgs, modulesPath, ... }:

# Most of the filesystems listed here are supposed to be overriden to default
# settings of whatever image format configuration this host system will import
# from nixos-generators.
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  fileSystems."/" = lib.mkOverride 2000 {
    label = "nixos";
    fsType = "ext4";
    autoResize = true;
  };
}
