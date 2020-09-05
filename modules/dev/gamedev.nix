# I've yet to delve into game development but here we are.
# This contains several toolchains such as Unity, Godot Engine, and Love.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.game-dev;
in
{
  options.modules.dev.game-dev =
    let mkBoolOption = bool: mkOption {
      type = types.bool;
      default = bool;
    }; in {
      defold.enable = mkBoolOption false;
      godot.enable = mkBoolOption false;
      unity3d.enable = mkBoolOption false;
    };

  config = {
    my.packages = with pkgs;
      (if cfg.godot.enable then [
        godot       # The Godot, not to be confused with a certain prosecutor.
      ] else []) ++

      (if cfg.defold.enable then [
        defold
      ] else []) ++

      (if cfg.unity3d.enable then [
        unstable.unity3d     # The Unity, not to be confused with a certain ideal.
        unstable.unityhub    # The ideal hub for your Unity projects.
      ] else []);
  };
}
