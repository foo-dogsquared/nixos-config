{ lib, pkgs, ... }:

lib.mkShell {
  packages = with pkgs; [
    nixfmt
    nixUnstable
  ];
}
