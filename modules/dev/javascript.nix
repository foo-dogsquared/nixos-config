# JavaScript, the poster boy of hated languages...
# I think it's pretty great, when it works.
# Otherwise, it is a disaster from its syntax and the massive ecosystem among others.
# Since I use/experiment with the ecosystem so stuff like Node and Deno are combined into one module file.
{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.dev.javascript;
in
{
  options.modules.dev.javascript =
    let mkBoolOption = bool: mkOption {
      type = types.bool;
      default = bool;
    }; in {
      deno.enable = mkBoolOption false;
      node.enable = mkBoolOption false;
  };

  config = {
    my.packages = with pkgs;
      (if cfg.deno.enable then [
        unstable.deno        # The Deltarune of Node.
      ] else []) ++

      (if cfg.node.enable then [
        nodejs      # The JavaScript framework/runtime where you don't have to kill someone for bad code. :)
      ] else []);
  };
}
