# Eh... I don't really do math but hey, I occasionally create visual aids sometimes.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.math;
in
{
  options.modules.dev.math =
    let mkEnableOption = mkOption {
      type = types.bool;
      default = false;
    }; in {
      enable = mkEnableOption;
      r.enable = mkEnableOption;
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      gnuplot       # I came for the plots.
      julia         # A statistics-focused languaged named after a character in an iconic fighting game.
      octave        # Matlab's hipster brother.
    ] ++

    (if cfg.r.enable then [
      R             # Rated G for accessibility.
      rstudio       # It's not that kind of studio.
    ] else []);
  };
}
