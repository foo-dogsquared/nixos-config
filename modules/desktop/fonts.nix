# My selection of fonts for this setup.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.fonts = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.fonts.enable {
    home.packages = with pkgs; [
      fira-code             # The programming font with fancy symbols.
      ibm-plex              # IBM's face.
      noto-fonts            # It's all about family and that's what so powerful about it.
      noto-fonts-cjk        # The universal font, Japanese-Chinese-Korean version.
      stix-otf              # The font you need for them math moonrunes.
    ];
  };
}
