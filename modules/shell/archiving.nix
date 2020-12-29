{ config, options, lib, pkgs, ... }:

with lib;

let cfg = config.modules.shell.archiving;
in {
  options.modules.shell.archiving = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      aria2 # The sequel to aria(1).
      fanficfare # youtube-dl for fanfics. Not that I read fanfics.
      youtube-dl # A program that can be sued for false advertisement as you can download from other video sources.
    ];
  };
}
