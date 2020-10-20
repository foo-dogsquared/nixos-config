{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.themes;
  my = import ../../lib { inherit pkgs; lib = lib; };
in
{
  assertions = [{
    assertion = my.countAttrs (_: x: x.enable) cfg < 2;
    message = "Can't have more than one theme enabled at a time";
  }];

  imports = [
    ./fair-and-square
  ];
}
