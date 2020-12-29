{ config, options, lib, pkgs, ... }:

with lib;

let cfg = config.modules.desktop.wine;
in {
  options.modules.desktop.wine = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      #airwave
      wine
      winetricks
    ];
  };
}
