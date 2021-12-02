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

    # Import the configuration with dconf.
    programs.dconf.enable = true;
    environment.etc."dconf/profile/gnome".text = "user-db:user";
    environment.etc."dconf/db/gnome".source = ./schemas;

    # I'm pretty sure this is already done but just to make sure.
    services.gnome.chrome-gnome-shell.enable = true;

    environment.systemPackages = with pkgs; [
      # It is required for custom menus in extensions.
      gnome-menus

      # My preferred extensions.
      gnomeExtensions.arcmenu
      gnomeExtensions.gsconnect
      gnomeExtensions.x11-gestures

      # Setting up Pop shell.
      gnome-shell-extension-pop-shell
      pop-launcher
      pop-launcher-plugin-duckduckgo-bangs
    ];
  };
}
