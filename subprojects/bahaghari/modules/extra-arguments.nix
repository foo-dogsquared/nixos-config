{ config, lib, pkgs, ... }:

let
  bahaghariLib = import ../lib { inherit pkgs; };
in
{
  # Setting the Bahaghari lib and extra utilities. The extra utilities are
  # largely based from the `utils` module argument found in NixOS systems.
  _module.args = {
    inherit bahaghariLib;
    bahaghariUtils = import ../utils { inherit config pkgs lib bahaghariLib; };
  };
}
