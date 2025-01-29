{ lib, pkgs, ... }:

{
  wrappers.yt-dlp-audio = {
    arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
    prependArgs = [ "--config-location" ./config/yt-dlp/audio.conf ];
  };

  wrappers.yt-dlp-video = {
    arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
    prependArgs = [ "--config-location" ./config/yt-dlp/video.conf ];
  };
}
