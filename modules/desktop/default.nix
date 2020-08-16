# My apps on my natural desktop environment.
{ config, options, lib, pkgs, ... }:

{
  imports = [
    ./browsers.nix
    ./files.nix
    ./fonts.nix
    ./graphics.nix
    ./multimedia.nix
    ./music.nix
  ];
}
