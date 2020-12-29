# All of the command-line tools will be put here.
{ config, options, lib, pkgs, ... }:

with lib; {
  imports = [ ./archiving.nix ./base.nix ./lf.nix ./zsh.nix ];
}
