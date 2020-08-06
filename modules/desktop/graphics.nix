# Being a hack fraud in "jack of all trades, master of none" thing, I also create "graphics".
# This includes tools for raster, vector, and 3D modelling.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.graphics;
in {
  options.modules.desktop.graphics = 
    let mkBoolDefault = bool: mkOption {
      type = types.bool;
      default = bool;
    }; in {
      enable = mkBoolDefault false;
      raster.enable = mkBoolDefault false;
      vector.enable = mkBoolDefault false;
      _3d.enable = mkBoolDefault false;
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        font-manager    # Self-explanatory name is self-explanatory.
        imagemagick     # A command-line tool for manipulating images.
      ] ++

      (if cfg.raster.enable then [
        gimp            # Adobe Photoshop replacement.
        krita           # A good painting program useful for "pure" digital arts.
        aseprite        # A pixel art editor.
      ] else []) ++

      (if cfg.vector.enable then [
        inkscape        # Adobe Illustrator (or Affinity Designer) replacement.
      ] else []) ++

      (if cfg._3d.enable then [
        blender         # It's a great 3D model editor.
        goxel           # It's a great voxel editor.
      ] else []);
  };
}
