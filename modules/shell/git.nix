# modules/shell/git.nix
# Git is great, Git is good, and it is not made out of wood.
# A version control system with the description of the closet furry behind the Linux kernel as the name.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.shell.git = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.git.enable {
    home.packages = with pkgs; [
      gitAndTools.delta
      gitAndTools.diff-so-fancy
    ];
  };
}
