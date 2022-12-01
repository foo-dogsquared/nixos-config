# All of the settings related to server systems.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.profiles.server;
in
{
  options.profiles.server = {
    enable = lib.mkEnableOption "server-related settings";
    headless.enable = lib.mkEnableOption "configuration for headless servers";
    hardened-config.enable = lib.mkEnableOption "additional hardened configuration for NixOS systems";
    cleanup.enable = lib.mkEnableOption "cleanup service for the system";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      assertions = [{
        assertion =
          !config.profiles.desktop.enable || !config.profiles.server.enable;
        message = ''
          Desktop profile is also enabled. The profiles `desktop` and `server`
          are mutually exclusive.
        '';
      }];

      # Most servers will have to be accessed for debugging so it is here. But
      # be sure to set the appropriate public keys for the users from that
      # server.
      services.openssh = lib.mkDefault {
        enable = true;

        # Both are good for hardening as it only requires the keyfiles.
        passwordAuthentication = false;
        permitRootLogin = "no";
      };

      # Most of the servers will be deployed with outside access in mind so
      # generate them certificates. Anything with a private network, ehh... so
      # just set it off.
      security.acme = {
        acceptTerms = true;
        defaults.email = "admin@foodogsquared.one";
      };

      # We're only going to deal with servers in English.
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
    })

    # We're only covering the most basic settings here.
    (lib.mkIf cfg.headless.enable {
      # So does sounds...
      sound.enable = false;

      # ...and Bluetooth because it's so insecure.
      hardware.bluetooth.enable = false;

      # And other devices...
      hardware.opentabletdriver.enable = false;
      services.printing.enable = false;
    })

    # Most of the things here are based from the Securing Debian document.
    (lib.mkIf cfg.hardened-config.enable {
      # Don't replace it mid-way! DON'T TURN LEFT!!!!
      security.protectKernelImage = true;

      # Hardened config equals hardened kernel.
      boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_0_hardened;

      # Be STRICT! MUAHAHAHAHA!!!!
      services.fail2ban = {
        enable = true;
        bantime-increment = {
          enable = true;
          factor = "4";
          maxtime = "24h";
        };
      };

      boot.kernel.sysctl = {
        # Disable system console entirely. We don't need it so get rid of it.
        "kernel.sysrq" = 0;
      };
    })

    (lib.mkIf cfg.cleanup.enable {
      # Weekly garbage collection of Nix store. Unlike in the desktop config,
      # this has looser requirements for the store items age for up to 21 days
      # older.
      nix.gc = {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 21d";
      };

      # Run the optimizer.
      nix.optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };

      # Journals cleanup every week.
      systemd.services.cleanup-logs = {
        description = "Weekly log cleanup";
        documentation = [ "man:journalctl(1)" ];
        script = "${pkgs.systemd}/bin/journalctl --vacuum-time=30d";
      };

      systemd.timers.clean-log = {
        description = "Weekly log cleanup";
        documentation = [ "man:journalctl(1)" ];
        wantedBy = [ "multi-user.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    })
  ]);
}
