# This is where extra desktop goodies can be found.
# As a note, this is not where you set the aesthetics of your graphical sessions.
# That can be found in the `themes` module.
{ config, options, lib, pkgs, ... }:

let cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    enable =
      lib.mkEnableOption "all desktop-related services and default programs";
    audio.enable =
      lib.mkEnableOption "all desktop audio-related services such as Pipewire";
    fonts.enable = lib.mkEnableOption "font-related configuration";
    hardware.enable =
      lib.mkEnableOption "the common hardware-related configuration";
    cleanup.enable = lib.mkEnableOption "activation of cleanup services";
  };

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
    })

    (lib.mkIf cfg.audio.enable {
      # Enable the preferred audio workflow.
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

      # Enable MPD-related services.
      services.mpd.enable = true;
      environment.systemPackages = with pkgs;
        [
          ncmpcpp # Has the worst name for a music client WTF?
        ];
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

      # More power optimizations!
      powerManagement.powertop.enable = true;

      # Welp, this is surprising...
      services.printing.enable = true;
    })

    (lib.mkIf cfg.cleanup.enable {
      # Weekly garbage collection of Nix store.
      nix.gc = {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 21d";
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
          timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
          };
        };
      };
    })
  ]);
}
