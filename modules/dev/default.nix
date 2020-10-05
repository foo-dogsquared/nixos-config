{ config, lib, ... }:

{
  imports = [
    ./android.nix
    ./base.nix
    ./cc.nix
    ./data.nix
    ./documentation.nix
    ./gamedev.nix
    ./java.nix
    ./javascript.nix
    ./lisp.nix
    ./math.nix
    ./perl.nix
    ./python.nix
    ./rust.nix
    ./vcs.nix
  ];
}
