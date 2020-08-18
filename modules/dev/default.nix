{ config, lib, ... }:

{
  imports = [
    ./android.nix
    ./base.nix
    ./cc.nix
    ./documentation.nix
    ./gamedev.nix
    ./java.nix
    ./javascript.nix
    ./lisp.nix
    ./math.nix
    ./perl.nix
    ./rust.nix
  ];
}
