# Themes are your graphical sessions.
# It also contains your aesthetics even specific workflow and whatnots.
# You can also show your desktop being modularized like this.
{ config, options, lib, pkgs, ... }:

let cfg = config.themes;
in {
  options.themes.disableLimit = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Whether to unlock the limit for themes. Since themes may overlap with
      packages and configurations, this should be enabled at your own risk.
    '';
  };

  imports = lib.mapAttrsToList (n: v: import v)
    (lib.filterAttrs (n: v: n != "default") (lib.filesToAttr ./.));

  config = {
    assertions = [{
      assertion =
        let enabledThemes = lib.countAttrs (_: theme: theme.enable) cfg.themes;
        in cfg.disableLimit && (enabledThemes < 2);
      message = "Can't have more than one theme enabled at any given time.";
    }];
  };
}
