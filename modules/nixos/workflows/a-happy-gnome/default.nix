{ config, lib, pkgs, ... }@attrs:

let
  cfg = config.workflows.workflows.a-happy-gnome;

  enabledExtensions = pkgs.writeTextFile {
    name = "a-happy-gnome-extensions";
    text = ''
      [org/gnome/shell]
      enabled-extensions=[${ lib.concatStringsSep ", " (lib.concatMap (e: [ ("'${e.extensionUuid}'") ]) cfg.shellExtensions) }]
    '';
  };

  # We're combining all of the custom dconf database into a package to be installed.
  dconfConfig = pkgs.runCommand "install-a-happy-gnome-dconf-keyfiles" { } ''
    mkdir -p $out/etc/dconf && cp --no-preserve=mode -r ${./config/dconf}/* $out/etc/dconf/
    install -Dm644 ${enabledExtensions} $out/etc/dconf/db/a-happy-gnome-conf.d/90-enabled-extensions.conf
  '';
in
{
  options.workflows.workflows.a-happy-gnome = {
    enable = lib.mkEnableOption "'A happy GNOME', foo-dogsquared's configuration of GNOME desktop environment";

    shellExtensions = lib.mkOption {
      type = with lib.types; listOf package;
      description = ''
        A list of GNOME Shell extensions to be included. Take note the package
        contain `passthru.extensionUuid` to be used for enabling the
        extensions.
      '';
      default = with pkgs.gnomeExtensions; [
        alphabetical-app-grid
        appindicator
        arcmenu
        burn-my-windows
        caffeine
        desktop-cube
        gsconnect
        just-perfection
        kimpanel
        paperwm
        pop-shell
        runcat
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
    (lib.mkIf (attrs ? _isfoodogsquaredcustom && attrs._isfoodogsquaredcustom) {
      profiles.i18n = lib.mkDefault {
        enable = true;
        ibus.enable = true;
      };
    })
  ]);
}
