# My apps on my natural desktop environment.
{ config, options, lib, pkgs, ... }:

{
  imports = [
    ./files.nix
    ./fonts.nix
    ./graphics.nix
    ./music.nix
  ];
}
