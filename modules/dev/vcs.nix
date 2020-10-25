# All of the version control systems are here!
{ config, options, lib, pkgs, ... }:

with lib;

let cfg = config.modules.dev.vcs;
in {
  options.modules.dev.vcs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [ gitAndTools.gitFull mercurial subversion ];
  };
}
