{ config, lib, ... }:

{
  imports = [
    ./android.nix
    ./base.nix
    ./cc.nix
    ./data.nix
    ./documentation.nix
    ./gamedev.nix
    ./go.nix
    ./java.nix
    ./lisp.nix
    ./math.nix
    ./perl.nix
    ./python.nix
    ./rust.nix
    ./vcs.nix
    ./web.nix
  ];
}
