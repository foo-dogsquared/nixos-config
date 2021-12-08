{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.research;
in {
  options.modules.tools.enable = lib.mkEnableOptions "Enable my usual toolbelt for research.";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      archivebox # The ultimate archiving solution!
      curl # The general purpose downloader.
      newsboat # Reading news easily on the command line?
      qbittorrent # The pirate's toolkit for downloading Linux ISOs.
      zotero # It's actually good at archiving despite not being a researcher myself.
    ];
  };
}
