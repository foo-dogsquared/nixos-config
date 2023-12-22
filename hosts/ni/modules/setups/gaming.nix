{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.gaming;
in
{
  options.hosts.ni.setups.gaming.enable =
    lib.mkEnableOption "gaming setup";

  config = lib.mkIf cfg.enable {
    # Bring all of the goodies.
    profiles.gaming = {
      enable = true;
      emulators.enable = true;
      retro-computing.enable = true;
    };

    # Bring more of them games.
    environment.systemPackages = with pkgs; [
      dwarf-fortress # Losing only means more possibilities to play.
      mindustry # Not a Minecraft industry simulator.
      minetest # Free Minecraft.
      the-powder-toy # Free micro-Minecraft.
    ];

    # This is somewhat used for streaming games from it.
    programs.steam.remotePlay.openFirewall = true;

    # Enable the Wine setup for Linux gaming with Windows games.
    profiles.desktop.wine.enable = true;

    # Yes... Play your Brawl Stars and Clash Royale in NixOS. :)
    virtualisation.waydroid.enable = true;
  };
}
