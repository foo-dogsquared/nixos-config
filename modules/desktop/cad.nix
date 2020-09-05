# Even if my designs are computer-aided, it's still horrible. :(
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.cad = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.cad.enable {
    my.packages = with pkgs; [
      freecad       # FREE AS A BIRD, FREE AS A ALL-YOU-CAN-EAT BUFFER!
      kicad         # The CAD for ki which is a form of energy found everywhere.
      leocad        # A CAD for leos, a well-known brand of toys.
      openscad      # A programmable CAD for programmers.
    ];
  };
}
