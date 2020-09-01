# A file manager for hipsters.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.shell.lf = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.lf.enable {
    my.packages = with pkgs; [
      lf
    ];

    my.home.xdg.configFile."lf" = {
      source = ../../config/lf;
      recursive = true;
    };
  };
}
