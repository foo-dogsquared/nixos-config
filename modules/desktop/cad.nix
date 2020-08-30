# Even if my designs are computer-aided, it's still horrible.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.music;
in {
  options.modules.desktop.music = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    my.packages = with pkgs; [
      freecad       # FREE AS A BIRD, FREE AS A ALL-YOU-CAN-EAT BUFFER!
      leocad        # A CAD for leos, a well-known brand of toys.
  };
}
