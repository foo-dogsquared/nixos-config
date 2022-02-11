# This is where extra desktop goodies can be found.
# As a note, this is not where you set the aesthetics of your graphical sessions.
# That can be found in the `themes` module.
{ inputs, config, options, lib, pkgs, ... }:

let cfg = config.profiles.desktop;
in {
  options.profiles.desktop = {
    enable =
      lib.mkEnableOption "all desktop-related services and default programs";
    audio.enable =
      lib.mkEnableOption "all desktop audio-related services such as Pipewire";
    fonts.enable = lib.mkEnableOption "font-related configuration";
    hardware.enable =
      lib.mkEnableOption "the common hardware-related configuration";
    cleanup.enable = lib.mkEnableOption "activation of cleanup services";
    wine = {
      enable = lib.mkEnableOption "Wine and Wine-related tools";
      package = lib.mkOption {
        type = lib.types.package;
        description = "The Wine package to be used for related tools.";
        default = pkgs.wineWowPackages.stable;
      };
    };
  };

  imports = [ inputs.nix-ld.nixosModules.nix-ld ];
  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      # Enable Flatpak for additional options for installing desktop applications.
      services.flatpak.enable = true;
      xdg.portal = {
        enable = true;
        gtkUsePortal = true;
        wlr.enable = true;
      };

      # Enable font-related options for more smoother and consistent experience.
      fonts.enableDefaultFonts = true;

      # Run unpatched binaries with these!
      environment.systemPackages = with pkgs; [
        nix-alien
        nix-index
        nix-index-update
      ];
    })

    (lib.mkIf cfg.audio.enable {
      # Enable the preferred audio workflow.
      sound.enable = false;
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # Enable running GNOME apps outside GNOME.
      programs.dconf.enable = true;
    })

    (lib.mkIf cfg.fonts.enable {
      fonts = {
        enableDefaultFonts = true;
        fontconfig = {
          enable = true;
          includeUserConf = true;

          defaultFonts = {
            monospace = [ "Iosevka" "Source Code Pro" ];
            sansSerif = [ "Source Sans Pro" "Noto Sans" ];
            serif = [ "Source Serif Pro" "Noto Serif" ];
          };
        };

        fonts = with pkgs; [
          iosevka

          # Noto font family
          noto-fonts
          noto-fonts-cjk
          noto-fonts-extra
          noto-fonts-emoji

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

      # Welp, this is surprising...
      services.printing.enable = true;
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
        dates = [ "daily" ];
      };

      # Clear logs that are more than a month old weekly.
      systemd = {
        services.clean-log = {
          description = "Weekly log cleanup";
          documentation = [ "man:journalctl(1)" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.systemd}/bin/journalctl --vacuum-time=30d";
          };
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

    # I try to avoid using Wine on NixOS because most of them uses FHS or something and I just want it to work but here goes.
    (lib.mkIf cfg.wine.enable {
      environment.systemPackages = with pkgs; [
        cfg.wine.package # The star of the show.
        winetricks # We do a little trickery with missing Windows runtimes.
        bottles # PlayOnLinux but better. :)
      ];
    })
  ]);
}
