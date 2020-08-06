# I create "music" (with no experience whatsoever) so here's my "music" workflow.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.music;
in {
  options.modules.desktop.music = 
    let mkBoolDefault = bool: mkOption {
      type = types.bool;
      default = bool;
    }; in {
      enable = mkBoolDefault false;
      composition = mkBoolDefault false;
      production = mkBoolDefault false;
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      (if cfg.composition.enable then [
        musescore           # A music composer for creating musical cheatsheets.
        soundfont-fluid     # A soundfont for it or something.
        supercollider       # Programming platform for synthesizing them 'zics.
      ] else []) ++

      (if cfg.production.enable then [
        ardour      # A DAW focuses on hardware recording but it can be used for something else.
        carla       # A plugin host useful for a consistent hub for them soundfonts and SFZs.
        helm        # A great synthesizer plugin.

        # As of 2020-07-03, lmms has some trouble regarding Qt or something so at least use the "unstable" channel just to be safe.
        # lmms
      ] else []);
  };
}
