# All of the settings related to server systems. Take note they cannot be used
# alongside the desktop profile since there are conflicting configurations
# between them.
{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.server;
in
{
  options.profiles.server = {
    enable = lib.mkEnableOption "server-related settings";
    headless.enable = lib.mkEnableOption "configuration for headless servers";
    hardened-config.enable = lib.mkEnableOption "additional hardened configuration for NixOS systems";
    cleanup.enable = lib.mkEnableOption "cleanup service for the system";
    auto-upgrade.enable = lib.mkEnableOption "unattended system upgrades";
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

      # Set the time zone. We're making it easier to track by assigning a
      # universal time zone and what could be more universal than the
      # "Coordinated Universal Time" (which does not abbreviates to UTC, WTF?).
      time.timeZone = lib.mkForce "UTC";

      # Add the usual manpages because it is not installed by default
      # apparently.
      environment.systemPackages = with pkgs; [ man-pages ];

      # Most servers will have to be accessed for debugging so it is here. But
      # be sure to set the appropriate public keys for the users from that
      # server.
      services.openssh = lib.mkDefault {
        enable = true;

        settings = {
          # Making it verbose for services such as fail2ban.
          LogLevel = "VERBOSE";

          # Both are good for hardening as it only requires the keyfiles.
          PasswordAuthentication = "no";
          PermitRootLogin = "no";
        };
      };

      # It is expected that server configurations should be complete
      # service-wise so we're not allowing user database to be mutable.
      users.mutableUsers = lib.mkForce false;

      # Most of the servers will be deployed with outside access in mind so
      # generate them certificates. Anything with a private network, ehh... so
      # just set it off.
      #
      # Don't forget to set your certificates or set DNS-related options for
      # this.
      security.acme = {
        acceptTerms = true;
        defaults.email = "admin+acme@foodogsquared.one";
      };

      # We're only going to deal with servers in English.
      i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
      i18n.supportedLocales = lib.mkForce [ "en_US.UTF-8/UTF-8" ];
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
      boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1_hardened;

      # Be STRICT! MUAHAHAHAHA!!!!
      services.fail2ban = {
        enable = true;
        bantime-increment = {
          enable = true;
          factor = "4";
          maxtime = "24h";
          overalljails = true;
        };
        extraPackages = with pkgs; [ ipset ];
      };

      boot.kernel.sysctl = {
        # Disable system console entirely. We don't need it so get rid of it.
        "kernel.sysrq" = 0;
      };
    })

    (lib.mkIf cfg.auto-upgrade.enable {
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
          "--update-input"
          "nixpkgs"
          "--commit-lock-file"
          "--no-write-lock-file"
        ];
        randomizedDelaySec = "1min";
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

      # Journal settings for retention.
      services.journald.extraConfig = ''
        MaxRetentionSec="3 month"
      '';
    })
  ]);
}
