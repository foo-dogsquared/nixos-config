# Themes are your graphical sessions.
# It also contains your aesthetics even specific workflow and whatnots.
# You can also show your desktop being modularized like this.
{ config, lib, pkgs, ... }:

let cfg = config.workflows;
in {
  options.workflows.disableLimit = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Whether to unlock the limit for workflows. Since workflows may overlap
      with packages and configurations, this should be enabled at your own
      risk.
    '';
  };

  imports = [
    ./a-happy-gnome
    ./knome
  ];

  config = {
    assertions = [{
      assertion =
        let
          countAttrs = pred: attrs:
            lib.count (attr: pred attr.name attr.value)
              (lib.mapAttrsToList lib.nameValuePair attrs);
          enabledThemes = countAttrs (_: theme: theme.enable) cfg.workflows;
        in
        cfg.disableLimit || (enabledThemes <= 1);
      message = "Can't have more than one theme enabled at any given time.";
    }];
  };
}
