# Muh consumer applications...
{ config, options, lib, pkgs, ... }:

with lib; {
  options.modules.desktop.multimedia = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.multimedia.enable {
    my.packages = with pkgs; [
      ffmpeg # The ultimate multimedia toolkit for everybody!
      hexchat # The ultimate IRC client for neckbeards.
      kdenlive # A decent free and open source video editor.
      mpv # The ultimate media player for hipsters.
      newsboat # The ultimate RSS aggregator for some person.
      obs-studio # Open Broadcasting Studio Studio, the reliable recording workflow.
      thunderbird # The ultimate email client for dumbasses like me.
      zathura # The ultimate PDF viewer for run-of-the-mill ricing.
    ];
  };
}
