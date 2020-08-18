# Muh consumer applications...
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.multimedia = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.multimedia.enable {
    my.packages = with pkgs; [
      hexchat           # The ultimate IRC client for neckbeards.
      mpv               # The ultimate media player for hipsters.
      newsboat          # The ultimate RSS aggregator for some person.
      obs-studio        # Open Broadcasting Studio Studio, the reliable recording workflow.
      obs-linuxbrowser  # OBS plugin for browser source.
      openshot-qt       # A decent video editor.
      thunderbird       # The ultimate email client for dumbasses like me.
      zathura           # The ultimate PDF viewer for run-of-the-mill ricing.
    ];
  };
}
