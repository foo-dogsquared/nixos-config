# Bahaghari's subproject.
{ lib, ... }:

{
  flake = {
    bahaghariLib = ../../subprojects/bahaghari/lib;
    homeModules.bahaghari = ../../subprojects/bahaghari/modules;
    nixosModules.bahaghari = ../../subprojects/bahaghari/modules;
    nixvimModules.bahaghari = ../../subprojects/bahaghari/modules;
  };
}
