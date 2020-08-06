{ config, options, lib, pkgs, ... }:

{
  imports = [
    ./desktop
    ./dev
    ./editors
    ./shell
  ];
}
