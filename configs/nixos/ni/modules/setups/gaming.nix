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
    suites.gaming = {
      enable = true;
      emulators.enable = true;
      retro-computing.enable = true;
    };

    programs.retroarch.cores = with pkgs.libretro; [
      pcsx2
      dolphin
      citra
      mame
    ];

    # Bring more of them games.
    environment.systemPackages = with pkgs; [
      rpcs3

      dwarf-fortress # Losing only means more possibilities to play.
      mindustry # Not a Minecraft industry simulator.
      minetest # Free Minecraft.
      the-powder-toy # Free micro-Minecraft.
      veloren # Free 3D mini-Minecraft.
    ];

    # This is somewhat used for streaming games from it.
    programs.steam.remotePlay.openFirewall = true;

    # Yes... Play your Brawl Stars and Clash Royale in NixOS. :)
    virtualisation.waydroid.enable = true;
  };
}
