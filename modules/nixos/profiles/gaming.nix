# NixOS gaming.
{ lib, options, config, pkgs, ... }:

let
  cfg = config.profiles.gaming;
in
{
  options.profiles.gaming = {
    enable = lib.mkEnableOption "foodogsquared's gaming setup";
    emulators.enable = lib.mkEnableOption "installation of individual game emulators";
    retro-computing.enable = lib.mkEnableOption "installation of retro computer systems";
  };

  # Just don't ask where you can sail getting the games. :)
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        # All-around emulator. Also what I'm mainly using for quickly
        # initializing sessions.
        retroarchFull
      ];

      # Enabling all hardware settings for the desktop (unless the user
      # explicitly disabled it).
      profiles.desktop.hardware.enable = lib.mkDefault true;

      # Enable the Wine setup for Linux gaming with Windows games.
      profiles.desktop.wine.enable = lib.mkDefault true;

      # Virtualize everything.
      profiles.dev.virtualization.enable = lib.mkDefault true;

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
