{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.themes.a-happy-gnome;
in
{
  options.modules.theme.a-happy-gnome.enable = lib.mkEnableOption "Enables my configuration of GNOME Shell.";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      chrome-gnome-shell

      gnomeExtensions.arcmenu
      gnomeExtensions.x11-gestures
      gnomeExtensions.gsconnect
    ];
  };
}
