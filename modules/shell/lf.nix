# A file manager for hipsters.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.shell.lf;
in {
  options.modules.shell.lf = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [ lf ];

    my.home.xdg.configFile."lf" = {
      source = ../../config/lf;
      recursive = true;
    };
  };
}
