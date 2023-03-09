{ config, options, lib, pkgs, ... }@attrs:

let
  name = "a-happy-gnome";
  cfg = config.workflows.workflows.a-happy-gnome;

  enabledExtensions = pkgs.writeTextFile {
    name = "a-happy-gnome-extensions";
    text = ''
      [org/gnome/shell]
      enabled-extensions=[${ lib.concatStringsSep ", " (lib.concatMap (e: [ ("'" + e.extensionUuid + "'") ]) cfg.shellExtensions) }]
    '';
  };

  # We're combining all of the custom dconf database into a package to be installed.
  dconfConfig = pkgs.runCommand "install-a-happy-gnome-dconf-keyfiles" { } ''
    install -Dm644 ${./config/dconf}/*.conf -t $out/etc/dconf/db/${name}-conf.d
    install -Dm644 ${enabledExtensions} $out/etc/dconf/db/${name}-conf.d/90-enabled-extensions.conf
  '';
in
{
  options.workflows.workflows.a-happy-gnome = {
    enable = lib.mkEnableOption "'A happy GNOME', foo-dogsquared's configuration of GNOME desktop environment";

    shellExtensions = lib.mkOption {
      type = with lib.types; listOf package;
      description = ''
        A list of GNOME Shell extensions to be included. Take note the package
        contain <literal>passthru.extensionUuid</literal> to be used for
        enabling the extensions.
      '';
      default = with pkgs.gnomeExtensions; [
        arcmenu
        appindicator
        alphabetical-app-grid
        burn-my-windows
        caffeine
        desktop-cube
        gsconnect
        x11-gestures
        kimpanel
        runcat
        just-perfection
        mpris-indicator-button
      ] ++ [
        pkgs.gnome-shell-extension-fly-pie
        pkgs.gnome-shell-extension-pop-shell
        pkgs.gnome-shell-extension-paperwm-latest
      ];
      example = lib.literalExpression ''
        with pkgs.gnomeExtensions; [
          appindicator
          gsconnect
          runcat
          just-perfection
        ];
      '';
      internal = true;
    };

    extraApps = lib.mkOption {
      type = with lib.types; listOf package;
      description = "A list of applications to be included in the theme.";
      default = with pkgs; [
        amberol # An unambitious music player.
        authenticator # 2-factor codes for 2-factor storages.
        blanket # Zen...
        eyedropper # Some nice eyedropper tool.
        gnome.dconf-editor # A saner version of Windows registry.
        dialect # Your gateway to polyglotting.
        fractal # Your gateway to the matrix.
        tangram # Your social media manager, probably.
        gnome-frog # Graphical OCR with Tesseract that I always wanted.
        gnome-solanum # Cute little matodor timers.
        gnome.gnome-boxes # Virtual machines, son.
        gnome.polari # Your gateway to one of the most hidden and cobweb-ridden parts of the internet. ;)
        shortwave # Yer' humble internet radio.
        ymuse # Simple MPD client.

        gnome.gnome-backgrounds # Default backgrounds.

        gnome-menus # It is required for custom menus in extensions.
        gnome-extension-manager # The cooler GNOME extensions app.
        gnome-search-provider-recoll # This is here for some reason.
      ];
      example = lib.literalExpression ''
        with pkgs; [ gnome.polari ];
      '';
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Enable GNOME and GDM.
      services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      # All GNOME-related additional options.
      services.gnome = {
        core-os-services.enable = true;
        core-shell.enable = true;
        core-utilities.enable = true;

        # It doesn't need to since we're not first-timers, yeah?
        gnome-initial-setup.enable = false;
      };

      # It makes Nix store directory read/write so no...
      services.packagekit.enable = false;

      # Setting up split DNS with systemd-resolved. The domains should already
      # be configured somewhere else.
      services.resolved.enable = true;
      networking.networkmanager.dns = "systemd-resolved";

      # Since we're using KDE Connect, we'll have to use gsconnect.
      programs.kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };

      # Bring all of the dconf keyfiles in there.
      programs.dconf = {
        enable = true;
        packages = [ dconfConfig ];

        # The `user` profile needed to set custom system-wide settings in GNOME.
        # Also, this is a private option so take precautions with this.
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
        # The application menu.
        junction
      ] ++ cfg.shellExtensions ++ cfg.extraApps;
    }

    # Check whether this is inside of my personal configuration or nah.
    (lib.mkIf (attrs ? _isInsideFds && attrs._isInsideFds) {
      profiles.i18n = lib.mkDefault {
        enable = true;
        ibus.enable = true;
      };
    })
  ]);
}
