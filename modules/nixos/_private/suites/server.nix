# All of the settings related to server systems. Take note they cannot be used
# alongside the desktop profile since there are conflicting configurations
# between them.
{ config, lib, pkgs, ... }:

let
  cfg = config.suites.server;
in
{
  options.suites.server = {
    enable = lib.mkEnableOption "server-related settings";
    cleanup.enable = lib.mkEnableOption "cleanup service for the system";
    auto-upgrade.enable = lib.mkEnableOption "unattended system upgrades";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = lib.singleton {
        assertion =
          !config.suites.desktop.enable || !config.suites.server.enable;
        message = ''
          Desktop profile is also enabled. The profiles `desktop` and `server`
          are mutually exclusive.
        '';
      };

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
      services.openssh = {
        enable = lib.mkDefault true;

        openFirewall = true;

        settings = {
          # Making it verbose for services such as fail2ban.
          LogLevel = "VERBOSE";

          # Both are good for hardening as it only requires the keyfiles.
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          PermitEmptyPasswords = "no";
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
    }

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
