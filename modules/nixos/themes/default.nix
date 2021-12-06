# Themes are your graphical sessions.
# It also contains your aesthetics even specific workflow and whatnots.
# You can also show your desktop being modularized like this.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.themes;
in
{
  assertions = [{
    assertion = (lib.countAttrs (_: theme: theme.enable) cfg) < 2;
    message = "Can't have more than one theme enabled at any given time.";
  }];

  imports = lib.mapAttrsToList (n: v: import v) (lib.filterAttrs (n: v: n != "default") (lib.filesToAttr ./.));
}
