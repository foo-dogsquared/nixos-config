# The entrypoint of the core. We're just requiring an empty attrset for now for
# forward compatibility in case it changes (90% it won't but I don't trust the
# remaining 10% ;p).
{ }:

{
  nixosModules = rec {
    default = ../modules/nixos;

    publicModules = default;
    privateModules = ../modules/nixos/_private;
    bahaghari = ../subprojects/bahaghari/modules;
  };

  homeModules = rec {
    default = ../modules/home-manager;

    publicModules = default;
    privateModules = ../modules/home-manager/_private;
    bahaghari = ../subprojects/bahaghari/modules;
  };

  nixvimModules = rec {
    default = ../modules/nixvim;

    publicModules = default;
    privateModules = ../modules/nixvim/_private;
    bahaghari = ../subprojects/bahaghari/modules;
  };

  wrapperManagerModules = rec {
    default = ../modules/wrapper-manager;

    publicModules = default;
    privateModules = ../modules/wrapper-manager/_private;
    bahaghari = ../subprojects/bahaghari/modules;
  };

  flakeModules = {
    default = ../modules/flake-parts;
    baseSetupConfig = ../modules/flake-parts/profiles/fds-template.nix;
  };

  lib = ../lib;
  bahaghariLib = ../subprojects/bahaghari/lib;
}
