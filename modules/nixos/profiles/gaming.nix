# NixOS gaming.
{ lib, config, pkgs, ... }:

let
  cfg = config.profiles.gaming;
in
{
  options.profiles.gaming = {
    enable = lib.mkEnableOption "foodogsquared's gaming setup";
    emulators.enable = lib.mkEnableOption "installation of individual game emulators";
    retro-computing.enable = lib.mkEnableOption "installation of retro computer systems";
    games.enable = lib.mkEnableOption "installation of certain FOSS games for funsies";
  };

  # Just don't ask where you can sail getting the games. :)
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        # All-around emulator. Also what I'm mainly using for quickly
        # initializing sessions.
        retroarchFull
      ];

      # Setup the go-to platform for Linux gaming. Most of the
      # games should work now with Proton integration.
      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
      };

      # Get your game on, go play...
      programs.gamemode.enable = true;

      # Enable them controllers in case you have one.
      hardware.steam-hardware.enable = true;
      hardware.xone.enable = true;
      hardware.xpadneo.enable = true;

      # Enabling all hardware settings for the desktop (unless the user
      # explicitly disabled it).
      profiles.desktop.hardware.enable = lib.mkDefault true;

      # Enable the Wine setup for Linux gaming with Windows games.
      profiles.desktop.wine.enable = lib.mkDefault true;

      # Yes... Play your Brawl Stars and Clash Royale in NixOS. :)
      virtualisation.waydroid.enable = lib.mkDefault true;
    }

    (lib.mkIf cfg.emulators.enable {
      environment.systemPackages = with pkgs; [
        ares # Another multi-system emulator but for accuracy.
        duckstation # Taking a gander with the original console.
        ppsspp # (PSP)-squared for foodogsquared.
        pcsx2 # A nice emulator with a nice (NOT) name.
        scummvm # Pretty scummy of us to put it here despite not being an emulator.
      ];
    })

    # Despite the module being for gaming setup, no individual games are
    # installed.
    (lib.mkIf cfg.games.enable {
      environment.systemPackages = with pkgs; [
        cataclysm-dda # Dwarf Fortress but in the future.
        dwarf-fortress # Dwarf Fortress.
        endless-sky # My other cocaine replacement.
        mindustry # Dwarf Fortress but with machineries.
        minetest # Dwarf Fortress but with voxels.
        openra # Dwarf Fortress but with futuristic armed civilizations.
        superTuxKart # Dwarf Fortress but with racing carts.
        starsector # My cocaine replacement.
        the-powder-toy # Microscopic Dwarf Fortress.
        wesnoth # Dwarf Fortress but with dwarves and fortresses.
        zeroad # Dwarf Fortress but with ancient armed civilizations.
      ];
    })

    # Old computer systems for old people.
    (lib.mkIf cfg.retro-computing.enable {
      environment.systemPackages = with pkgs; [
        dosbox-staging
        fuse-emulator
        vice
        x16-emulator
      ];
    })
  ]);
}
