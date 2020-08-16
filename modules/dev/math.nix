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
      python.enable = mkEnableOption;
      r.enable = mkEnableOption;
  };

  config = {
    my.packages = with pkgs; [
      gnuplot       # I came for the plots.
      octave        # Matlab's hipster brother.
    ] ++

    (if cfg.python.enable then [
      python        # Serious question: do I really need to install this?
      python38Packages.sympy        # The Python library that always being noticed.
    ] else []) ++

    (if cfg.r.enable then [
      R             # Rated G for accessibility.
    ] else []);
  };
}
