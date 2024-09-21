{ lib, ... }:

{
  flake = {
    wrapperManagerLib = ../../subprojects/wrapper-manager-fds/lib;
    wrapperManagerModules = ../../subprojects/wrapper-manager-fds/modules/wrapper-manager;
    homeModules.wrapper-manager = ../../subprojects/wrapper-manager-fds/modules/env/home-manager;
    nixosModules.wrapper-manager = ../../subprojects/wrapper-manager-fds/modules/env/nixos;
  };
}
