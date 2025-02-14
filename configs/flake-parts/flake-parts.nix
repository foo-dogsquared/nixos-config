# This is simply to make using my flake modules a bit easier for my private
# configurations.
{ config, lib, ... }:

{
  flake.flakeModules = {
    default = ../../modules/flake-parts;

    # A little module to make it convenient for setting up the baseline of all
    # of the configurations.
    baseSetupsConfig = ./setups.nix;
  };
}
