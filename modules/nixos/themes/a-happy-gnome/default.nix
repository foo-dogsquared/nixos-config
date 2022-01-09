{ config, options, lib, pkgs, ... }:

# TODO: Custom dconf database which is not yet possible.
# See https://github.com/NixOS/nixpkgs/issues/54150 for more details.
let
  name = "a-happy-gnome";
  dconf = pkgs.gnome3.dconf;
  customDconfDb = pkgs.stdenv.mkDerivation {
    name = "${name}-dconf-db";
    buildCommand = "${dconf}/bin/dconf compile $out ${./config/dconf}";
  };
  cfg = config.themes.themes.a-happy-gnome;
in
{
  options.themes.themes.a-happy-gnome.enable = lib.mkEnableOption "'A happy GNOME', foo-dogsquared's configuration of GNOME desktop environment";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Since we're using KDE Connect, we'll have to use gsconnect.
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    # Don't need most of the GNOME's offering so...
    environment.gnome.excludePackages = with pkgs.gnome; [
      gedit
      eog
      geary
      totem
      epiphany
      gnome-terminal
      gnome-music
      gnome-software
      yelp
    ] ++ (with pkgs; [
      gnome-user-docs
      gnome-tour
    ]);

    # I'm pretty sure this is already done but just to make sure.
    services.gnome.chrome-gnome-shell.enable = true;

    environment.systemPackages = with pkgs; [
      # It is required for custom menus in extensions.
      gnome-menus

      # Good ol' unofficial preferences tool.
      gnome.gnome-tweaks

      # My preferred extensions.
      gnomeExtensions.arcmenu
      gnomeExtensions.gsconnect
      gnomeExtensions.x11-gestures
      gnomeExtensions.kimpanel
      gnomeExtensions.runcat
      gnomeExtensions.just-perfection

      # TODO: Use from nixpkgs once fly-pie is fixed.
      gnome-shell-extension-fly-pie

      # Setting up Pop shell.
      gnome-shell-extension-pop-shell
      pop-launcher
      pop-launcher-plugin-duckduckgo-bangs
    ];
  };
}
