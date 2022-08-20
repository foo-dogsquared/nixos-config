# This is where extra desktop goodies can be found.
# As a note, this is not where you set the aesthetics of your graphical sessions.
# That can be found in the `themes` module.
{ config, options, lib, pkgs, ... }:

let cfg = config.profiles.system;
in {
  options.profiles.system = {
    enable =
      lib.mkEnableOption "all desktop-related services and default programs";
    audio.enable =
      lib.mkEnableOption "all desktop audio-related services such as Pipewire";
    fonts.enable = lib.mkEnableOption "font-related configuration";
    hardware.enable =
      lib.mkEnableOption "the common hardware-related configuration";
    cleanup.enable = lib.mkEnableOption "activation of cleanup services";
    autoUpgrade.enable = lib.mkEnableOption "auto-upgrade service with this system";
    wine = {
      enable = lib.mkEnableOption "Wine and Wine-related tools";
      package = lib.mkOption {
        type = lib.types.package;
        description = "The Wine package to be used for related tools.";
        default = pkgs.wineWowPackages.stable;
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      # Enable Flatpak for additional options for installing desktop applications.
      services.flatpak.enable = true;
      xdg.portal.enable = true;

      environment.etc =
        let
          urls = {
            "flathub" = {
              url = "https://flathub.org/repo/flathub.flatpakrepo";
              sha256 = "sha256:0fm0zvlf4fipqfhazx3jdx1d8g0mvbpky1rh6riy3nb11qjxsw9k";
            };
            "flathub-beta" = {
              url = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
              sha256 = "sha256:01kj1yza51dd4vcr04j49lx0mnivldpzxyny4zq3jilxkwyawb2q";
            };
            "gnome-nightly" = {
              url = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
              sha256 = "sha256:10y9a50m2jz8p3avd8kqw5i7lyl71xwmc2mnrdicv0mgj1b6wndc";
            };
            "kdeapps" = {
              url = "https://distribute.kde.org/kdeapps.flatpakrepo";
              sha256 = "sha256:18kscw44ff6bjx1abvffzk0js01w51vgh4h0rwpa76hc0r0ps8bl";
            };
          };
        in
        lib.mapAttrs'
          (name: remote: lib.nameValuePair "flatpak/remotes.d/${name}.flatpakrepo" {
            source = pkgs.fetchurl remote;
          })
          urls;

      programs.extra-container.enable = true;

      # Enable font-related options for more smoother and consistent experience.
      fonts.fontconfig.enable = true;

      # Run unpatched binaries with these!
      programs.nix-ld.enable = true;
      environment.systemPackages = with pkgs; [
        nix-alien
        nix-index
        nix-index-update
      ];

      # Enable running GNOME apps outside GNOME.
      programs.dconf.enable = true;
    })

    (lib.mkIf cfg.audio.enable {
      # Enable the preferred audio workflow.
      sound.enable = false;
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;

        # This is enabled by default but I want to explicit since
        # this is my preferred way of managing anyways.
        wireplumber.enable = true;

        # Enable all the bi-...bridges.
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    })

    (lib.mkIf cfg.fonts.enable {
      fonts = {
        enableDefaultFonts = true;
        fontDir.enable = true;
        fontconfig = {
          enable = true;
          includeUserConf = true;

          defaultFonts = {
            monospace = [ "Iosevka" "Jetbrains Mono" "Source Code Pro" ];
            sansSerif = [ "Source Sans Pro" "Noto Sans" ];
            serif = [ "Source Serif Pro" "Noto Serif" ];
            emoji = [ "Noto Color Emoji" ];
          };
        };

        fonts = with pkgs; [
          # Some monospace fonts.
          iosevka
          jetbrains-mono

          # Noto font family
          noto-fonts
          noto-fonts-cjk
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-extra
          noto-fonts-emoji
          noto-fonts-emoji-blob-bin

          # Adobe Source font family
          source-code-pro
          source-sans-pro
          source-han-sans
          source-serif-pro
          source-han-serif
          source-han-mono

          # Math fonts
          stix-two
          xits-math
        ];
      };
    })

    (lib.mkIf cfg.hardware.enable {
      # Enable tablet support with OpenTabletDriver.
      hardware.opentabletdriver.enable = true;

      # Enable support for Bluetooth.
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluezFull;
      };
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

      # Clear logs that are more than a month old weekly.
      systemd = {
        services.clean-log = {
          description = "Weekly log cleanup";
          documentation = [ "man:journalctl(1)" ];
          script = "${pkgs.systemd}/bin/journalctl --vacuum-time=30d";
        };

        timers.clean-log = {
          description = "Weekly log cleanup";
          documentation = [ "man:journalctl(1)" ];
          wantedBy = [ "multi-user.target" ];
          timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
          };
        };
      };
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
          "--update-input" "nixpkgs"
          "--commit-lock-file"
          "--no-write-lock-file"
        ];
        randomizedDelaySec = "1min";
      };
    })

    # I try to avoid using Wine on NixOS because most of them uses FHS or
    # something and I just want it to work but here goes.
    (lib.mkIf cfg.wine.enable {
      environment.systemPackages = with pkgs; [
        cfg.wine.package # The star of the show.
        winetricks # We do a little trickery with missing Windows runtimes.
        bottles # PlayOnLinux but better. :)
      ];
    })
  ]);
}
