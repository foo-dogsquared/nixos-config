# Seeing systemd as a great software is my guilty pleasure.
# Here's where services are declared.
{ config, options, lib, pkgs, ... }:

{
  imports = [
    ./recoll.nix
  ];
}
