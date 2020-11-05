# Web development, the poster boy of hated programming subsets...
# I think it's pretty great, when it works.
# Otherwise, it is a disaster from the massive ecosystem among others.
# Since I use/experiment with the ecosystem so stuff like Node and Deno are combined into one module file.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.web;
in {
  options.modules.dev.web = let
    mkBoolOption = bool:
      mkOption {
        type = types.bool;
        default = bool;
      };
  in {
    enable = mkBoolOption false;
    javascript = {
      enable = mkBoolOption false;
      deno.enable = mkBoolOption false;
      node.enable = mkBoolOption false;
    };
    php.enable = mkBoolOption false;
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs;
      [ caddy ] ++ (if cfg.javascript.deno.enable then
        [
          deno # The Deltarune of Node.
        ]
      else
        [ ]) ++

      (if cfg.javascript.node.enable then
        [
          nodejs # The JavaScript framework/runtime where you don't have to kill someone for bad code. :)
        ]
      else
        [ ]) ++

      (if cfg.php.enable then [
        php # Behold, the most hated language (at least in my experience).
        phpPackages.composer # Composes PHP projects prematurely.
        phpPackages.phpcs # Quality control tool.
        phpPackages.php-cs-fixer # Fixes your incorrectly formatted dirt.
      ] else
        [ ]);
  };
}
