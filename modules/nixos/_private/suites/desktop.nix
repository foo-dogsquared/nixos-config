# This is where extra desktop goodies can be found.
# As a note, this is not where you set the aesthetics of your graphical sessions.
# That can be found in the `themes` module.
{ config, lib, pkgs, foodogsquaredLib, ... }:

let cfg = config.suites.desktop;
in {
  options.suites.desktop = {
    enable =
      lib.mkEnableOption "basic desktop-related services and default programs";
    audio.enable =
      lib.mkEnableOption "audio production setup";
    windows-compatibility.enable =
      lib.mkEnableOption "Windows compatibility toolkit";
    cleanup.enable =
      lib.mkEnableOption "activation of various cleanup services";
    autoUpgrade.enable =
      lib.mkEnableOption "auto-upgrade service with this system";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      # Enable Flatpak for additional options for installing desktop applications.
      services.flatpak.enable = true;
      xdg.portal.enable = true;

      environment.etc = let
        urls = {
          "flathub" = {
            url = "https://flathub.org/repo/flathub.flatpakrepo";
            hash = "sha256-M3HdJQ5h2eFjNjAHP+/aFTzUQm9y9K+gwzc64uj+oDo=";
          };
          "flathub-beta" = {
            url = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
            hash = "sha256-WCyuPJ+dRjnwJ976/m+jO9oKOk1EEpDZJq2For4PcgY=";
          };
          "gnome-nightly" = {
            url = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
            hash = "sha256-rFluVpCvgs1iy7YKVnkPh3p6YuF4orbVuOhLUUFRyYM=";
          };
          "kdeapps" = {
            url = "https://distribute.kde.org/kdeapps.flatpakrepo";
            hash = "sha256-dCF9QQYMmqMuzwAS+HYoPAAtwfzO7aVCl8s4RwhneqI=";
          };
        };
      in lib.mapAttrs' (name: remote:
        lib.nameValuePair "flatpak/remotes.d/${name}.flatpakrepo" {
          source = pkgs.fetchurl remote;
        }) urls;

      programs.extra-container.enable = true;

      # Enable font-related options for more smoother and consistent experience.
      fonts.fontconfig.enable = true;

      # Run unpatched binaries with these!
      programs.nix-ld = {
        enable = true;
        libraries = let
          xorgLibs = with pkgs.xorg; [
            libX11
            libXScrnSaver
            libXcomposite
            libXcursor
            libXdamage
            libXext
            libXfixes
            libXi
            libXrandr
            libXrender
            libXtst
            libxcb
            libxkbfile
            libxshmfence
          ];
          commonLibs = with pkgs; [
            alsa-lib
            cairo
            freetype
            dbus
            icu
            libGL
            libnotify
            mesa
            nss
            pango
            pipewire
          ];
          desktopLibs = with pkgs; [ qt5.full qt6.full gtk3 gtk4 ];
        in commonLibs ++ xorgLibs ++ desktopLibs;
      };

      environment.systemPackages = with pkgs;
        [
          steam-run # For the heathens that still uses FHS.
        ];

      # Enable running GNOME apps outside GNOME.
      programs.dconf.enable = true;

      # Enable virtual camera.
      boot.kernelModules = [ "v4l2loopback" ];
    })

    (lib.mkIf cfg.windows-compatibility.enable {
      environment.systemPackages = with pkgs; [
        # Setup the WINE environment.
        wineWowPackages.stable
        bottles # The Windows environment package manager.
      ];
    })

    (lib.mkIf cfg.audio.enable {
      environment.systemPackages = lib.optionals cfg.windows-compatibility.enable (with pkgs; [
        yabridge
        yabridgectl
      ]);

      environment.profileRelativeSessionVariables =
        let
          audioPluginFormats =
            [ "LV2" "DSSI" "CLAP" ]
            ++ lib.optionals cfg.windows-compatibility.enable [ "VST" "VST3" ];
        in
        foodogsquaredLib.genAttrs' audioPluginFormats (s: lib.nameValuePair "${s}_PATH" [ "/lib" ]);
    })

    (lib.mkIf cfg.cleanup.enable {
      # Weekly garbage collection of Nix store.
      nix.gc = {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # Run the optimizer.
      nix.optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };

      # Journal settings for retention.
      services.journald.extraConfig = ''
        MaxRetentionSec="3 month"
      '';
    })

    (lib.mkIf cfg.autoUpgrade.enable {
      system.autoUpgrade = {
        enable = true;
        flake = "github:foo-dogsquared/nixos-config";
        allowReboot = true;
        persistent = true;
        rebootWindow = {
          lower = "22:00";
          upper = "00:00";
        };
        dates = "weekly";
        flags = [
          "--no-write-lock-file"
        ];
        randomizedDelaySec = "1min";
      };
    })
  ]);
}
