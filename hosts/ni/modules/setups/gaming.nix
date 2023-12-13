{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.gaming;
in
{
  options.hosts.ni.setups.gaming.enable = lib.mkEnableOption "gaming setup";

  config = lib.mkIf cfg.enable {
    # Bring all of the goodies.
    profiles.gaming = {
      enable = true;
      emulators.enable = true;
      retro-computing.enable = true;
    };

    environment.systemPackages = with pkgs; [
      dwarf-fortress
      mindustry
      minetest
      the-powder-toy
    ];

    # This is somewhat used for streaming games from it.
    programs.steam.remotePlay.openFirewall = true;
  };
}
