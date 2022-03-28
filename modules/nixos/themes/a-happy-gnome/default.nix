{ config, options, lib, pkgs, ... }:

let
  name = "a-happy-gnome";
  cfg = config.themes.themes.a-happy-gnome;
  dconfConfig = pkgs.runCommand "install-a-happy-gnome-dconf-keyfiles" {} ''
    install -Dm644 ${./config/dconf}/*.conf -t $out/etc/dconf/db/${name}-conf.d
  '';
in
{
  options.themes.themes.a-happy-gnome.enable = lib.mkEnableOption "'A happy GNOME', foo-dogsquared's configuration of GNOME desktop environment";

  config = lib.mkIf cfg.enable {
    # Enable GNOME and GDM.
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

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
      yelp
    ] ++ (with pkgs; [
      gnome-user-docs
      gnome-tour
    ]);

    # I'm pretty sure this is already done but just to make sure.
    services.gnome.chrome-gnome-shell.enable = true;

    # Bring all of the dconf keyfiles in there.
    programs.dconf = {
      enable = true;
      packages = [ dconfConfig ];

      # The `user` profile needed to set custom system-wide settings in GNOME.
      profiles.user = pkgs.writeTextFile {
        name = "a-happy-gnome";
        text = ''
          user-db:user
          system-db:${name}-conf
        '';
      };
    };

    xdg.mime = {
      enable = true;
      defaultApplications = {
        # Default application for web browser.
        "text/html" = "re.sonny.Junction.desktop";

        # Default handler for all files. Not all applications will
        # respect it, though.
        "x-scheme-handler/file" = "re.sonny.Junction.desktop";

        # Default handler for directories.
        "inode/directory" = "re.sonny.Junction.desktop";
      };
    };

    environment.systemPackages = with pkgs; [
      # The preferred terminal.
      kitty

      # The application menu.
      junction

      # It is required for custom menus in extensions.
      gnome-menus

      # Good ol' unofficial preferences tool.
      gnome.gnome-tweaks

      # A third-party extension manager.
      gnome-extension-manager

      # My preferred extensions.
      gnomeExtensions.arcmenu
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
      gnomeExtensions.x11-gestures
      gnomeExtensions.kimpanel
      gnomeExtensions.runcat
      gnomeExtensions.just-perfection
      gnomeExtensions.mpris-indicator-button

      # TODO: Use from nixpkgs once fly-pie is fixed.
      gnome-shell-extension-fly-pie

      # TODO: Also these two...
      gnome-shell-extension-burn-my-windows
      gnome-shell-extension-desktop-cube

      # GNOME search providers.
      gnome-search-provider-recoll
    ];
  };
}
