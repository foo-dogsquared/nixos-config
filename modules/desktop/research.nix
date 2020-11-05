# I'm not in academia but I like managing my library resources.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.research;
in {
  options.modules.desktop.research = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      exiftool # A file metadata reader/writer/helicopter.
      zotero # An academic's best friend.
    ];
  };
}
