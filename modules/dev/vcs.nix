# All of the version control systems are here!
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.vcs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.vcs.enable {
    my.packages = with pkgs; [
      gitAndTools.gitFull
      mercurial
      subversion
    ];
  };
}
