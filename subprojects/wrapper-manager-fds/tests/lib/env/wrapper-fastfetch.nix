{ lib, pkgs, ... }:

{
  wrappers.fastfetch = {
    arg0 = lib.getExe' pkgs.fastfetch "fastfetch";
    appendArgs = [ "--logo" "Guix" ];
    env.NO_COLOR = "1";
  };
}
