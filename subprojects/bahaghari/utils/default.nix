{ config, lib, pkgs, bahaghariLib }@args:

let callLib = path: import path args;
in { tinted-theming = callLib ./tinted-theming.nix; }
