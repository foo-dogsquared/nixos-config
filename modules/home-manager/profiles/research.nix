{ config, options, lib, pkgs, ... }:

let cfg = config.profiles.research;
in {
  options.profiles.research.enable =
    lib.mkEnableOption "my usual toolbelt for research";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      archivebox # The ultimate archiving solution created by a pirate!
      curl # The general purpose downloader.
      fanficfare # It's for the badly written fanfics.
      internetarchive # All of the potential vintage collection of questionable materials at your fingertips.
      newsboat # Reading news easily on the command line?
      qbittorrent # The pirate's toolkit for downloading Linux ISOs.
      yt-dlp # The general purpose video downloader.
      zotero # It's actually good at archiving despite not being a researcher myself.
    ];

    services.syncthing.enable = true;
  };
}
