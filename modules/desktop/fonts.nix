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
    # Enable fontconfig to easily discover fonts installed from home-manager.
    fonts = {
      fontDir.enable = true;
      enableDefaultFonts = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [ "Source Sans Pro" "IBM Plex Sans" ];
          serif = [ "Source Serif Pro" "IBM Plex Serif" ];
          monospace = [ "Source Code Pro" "IBM Plex Mono" ];
        };
      };

      fonts = with pkgs; [
       dejavu_fonts          # Makes you feel like you've seen them before.
       fira-code             # The programming font with fancy symbols.
       ibm-plex              # IBM's face, is it professional?
       iosevka               # The fancy monofont with fancy ligatures.
       jetbrains-mono        # Jet to the face, land on the brains.
       latinmodern-math      # The ol' mathematical typeface.
       noto-fonts            # It's all about family and that's what so powerful about it.
       noto-fonts-cjk        # I don't condone anime.
       source-code-pro       # The Adobe pro code.
       source-serif-pro      # The Adobe serif code.
       source-sans-pro       # The above descriptions doesn't make much sense.
       stix-otf              # The font you need for them math moonrunes.
      ];
    };
  };
}
