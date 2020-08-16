# My browsers are my buddies on surfing the web.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.browsers;
in
{
  options.modules.desktop.browsers =
    let mkBoolDefault = bool: mkOption {
      type = types.bool;
      default = false;
    }; in {
      brave.enable = mkBoolDefault false;
      firefox.enable = mkBoolDefault false;
      chromium.enable = mkBoolDefault false;
      nyxt.enable = mkBoolDefault false;
  };

  config = {
    my.packages = with pkgs;
      (if cfg.brave.enable then [ brave ] else []) ++
      (if cfg.firefox.enable then [ firefox-bin ] else []) ++
      (if cfg.chromium.enable then [ chromium ] else []) ++
      (if cfg.nyxt.enable then [ next ] else []);
  };
}
