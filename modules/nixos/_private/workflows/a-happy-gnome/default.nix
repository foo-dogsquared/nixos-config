{ config, lib, pkgs, ... }:

let
  cfg = config.workflows.workflows.a-happy-gnome;
in
{
  options.workflows.workflows.a-happy-gnome = {
    enable = lib.mkEnableOption "'A happy GNOME', foo-dogsquared's configuration of GNOME desktop environment";

    shellExtensions = lib.mkOption {
      type = with lib.types; listOf package;
      description = ''
        A list of GNOME Shell extensions to be included. Take note the package
        should contain `passthru.extensionUuid` to be used for enabling the
        extensions.
      '';
      default = with pkgs.gnomeExtensions; [
        alphabetical-app-grid
        appindicator
        arcmenu
        burn-my-windows
        caffeine
        fly-pie
        gsconnect
        just-perfection
        kimpanel
        light-style
        paperwm
        runcat
        windownavigator
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
        adw-gtk3 # A nice theme for GTK3.
        amberol # An unambitious music player.
        authenticator # 2-factor codes for 2-factor storages.
        blanket # Zen...
        dialect # Your gateway to polyglotting.
        eyedropper # Some nice eyedropper tool.
        flowtime # Some nice timer for those overworking.
        fractal # Your gateway to the matrix.
        gnome-decoder # Go with them QR codes.
        gnome-frog # Graphical OCR with Tesseract that I always wanted.
        gnome-solanum # Cute little matodor timers.
        gnome.dconf-editor # A saner version of Windows registry.
        gnome.gnome-boxes # Virtual machines, son.
        gnome.polari # Your gateway to one of the most hidden and cobweb-ridden parts of the internet. ;)
        gradience # Make it rain!
        handbrake # Take a break from those custom ffmpeg conversion scripts.
        shortwave # Yer' humble internet radio.
        tangram # Your social media manager, probably.
        ymuse # Simple MPD client.

        gnome.gnome-backgrounds # Default backgrounds.

        gnome-menus # It is required for custom menus in extensions.
        gnome-extension-manager # The cooler GNOME extensions app.
        gnome-search-provider-recoll # This is here for some reason.

        # Nautilus extensions
        nautilus-annotations
        nautilus-open-any-terminal
      ];
      example = lib.literalExpression ''
        with pkgs; [ gnome.polari ];
      '';
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable GNOME and GDM.
    services.xserver = {
      enable = true;
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

    # Since we're using KDE Connect, we'll have to use gsconnect.
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    # Bring all of the dconf keyfiles in there.
    programs.dconf = {
      enable = true;
      profiles.user.databases = lib.singleton {
        # Get them keyfiles.
        keyfiles = [ ./config/dconf ];

        settings = lib.mkMerge [
          {
            "org/gnome/desktop/search-providers" = {
              disabled = [
                "org.gnome.seahorse.Application.desktop"
                "org.gnome.Photos.desktop"
                "org.gnome.Epiphany.desktop"
                "app.drey.Dialect.desktop"
                "com.belmoussaoui.Authenticator.desktop"
              ];
            };
            "org/gnome/shell" = {
              enabled-extensions = builtins.map (p: p.extensionUuid) cfg.shellExtensions;
            };
          }

          # Disable all of the messenger's notification (only the annoying
          # ones).
          (lib.listToAttrs
            (builtins.map
              (app:
                lib.nameValuePair
                  "org/gnome/desktop/notifications/application/${app}"
                  { show-banners = false; })
              [
                "re-sonny-tangram"
                "org-gnome-polari"
                "io-github-hexchat"
                "org-gnome-evolution-alarm-notify"
                "thunderbird"
              ]))
        ];
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
  };
}
