# My apps on my natural desktop environment.
{ config, options, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./browsers.nix
    ./cad.nix
    ./files.nix
    ./fonts.nix
    ./graphics.nix
    ./multimedia.nix
    ./research.nix
    ./wine.nix
  ];
}
