{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.themes.a-happy-gnome;
in
{
  options.modules.themes.a-happy-gnome.enable = lib.mkEnableOption "Enables my configuration of GNOME Shell.";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # I'm pretty sure this is already done but just to make sure.
    services.gnome.chrome-gnome-shell.enable = true;

    environment.systemPackages = with pkgs; [
      gnomeExtensions.arcmenu
      gnomeExtensions.x11-gestures
      gnomeExtensions.gsconnect
    ];
  };
}
