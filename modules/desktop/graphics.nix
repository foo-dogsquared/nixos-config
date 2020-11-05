# Being a hack fraud in "jack of all trades, master of none" thing, I also create "graphics".
# This includes tools for raster, vector, and 3D modelling.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.graphics;
in {
  options.modules.desktop.graphics = let
    mkBoolDefault = bool:
      mkOption {
        type = types.bool;
        default = bool;
      };
  in {
    enable = mkBoolDefault false;
    programmable.enable = mkBoolDefault false;
    raster.enable = mkBoolDefault false;
    vector.enable = mkBoolDefault false;
    _3d.enable = mkBoolDefault false;
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs;
      [
        font-manager # Self-explanatory name is self-explanatory.
        imagemagick7 # A command-line tool for manipulating images.
        graphviz # The biz central for graphical flowcharts.
      ] ++

      (if cfg.programmable.enable then
        [
          processing # A visually-oriented language with an energertic train conductor as the mascot.
        ]
      else
        [ ]) ++

      (if cfg.raster.enable then [
        gimp # Adobe Photoshop replacement.
        krita # A good painting program useful for "pure" digital arts.
        aseprite-unfree # A pixel art editor.
      ] else
        [ ]) ++

      (if cfg.vector.enable then
        [
          inkscape # Adobe Illustrator (or Affinity Designer) replacement.
        ]
      else
        [ ]) ++

      (if cfg._3d.enable then [
        blender # It's a great 3D model editor.
        goxel # It's a great voxel editor.
      ] else
        [ ]);
  };
}
