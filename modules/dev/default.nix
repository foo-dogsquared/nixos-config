{ config, lib, ... }:

{
  imports = [
    ./base.nix
    ./cc.nix
    ./documentation.nix
    ./gamedev.nix
    ./javascript.nix
    ./lisp.nix
    ./rust.nix
  ];
}
