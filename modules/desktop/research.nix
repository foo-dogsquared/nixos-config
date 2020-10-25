# I'm not in academia but I like managing my library resources.
{ config, options, lib, pkgs, ... }:

with lib; {
  options.modules.desktop.research = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.research.enable {
    my.packages = with pkgs; [
      exiftool # A file metadata reader/writer/helicopter.
      zotero # An academic's best friend.
    ];
  };
}
