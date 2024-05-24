{ config, lib, pkgs, bahaghariLib }:

let
  callLib = path: import path { inherit config lib pkgs bahaghariLib; };
in
{
  tinted-theming = callLib ./tinted-theming.nix;
}
