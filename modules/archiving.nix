# All of your embarrassing moments, marked here forever.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.archiving;
in
{
  options.modules.archiving.enable = lib.mkEnableOption "Install and configure archiving tools.";

  # This is not going to set BorgBackup NixOS services for you.
  # Please do it for host-specific configs instead.
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      archivebox    # Create by ye' old pirate.
      borgbackup    # I'm pretty sure this is named after some thing from a franchise somewhere but I'm not omnipresent.
      borgmatic     # For those insisting on configurations for BorgBackup.
      fanficfare    # Your fanfics in my hard drive? Pay me rent first.
      yt-dlp        # More active fork after youtube-dl has been striked.
    ];
  };
}
