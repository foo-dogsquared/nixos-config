{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.bleachbit;

  cleaners = cfg.cleaners ++ lib.optionals cfg.withBrowserCleanup [
    "brave.cache"
    "brave.form_history"
    "brave.history"
    "brave.passwords"
    "chromium.cache"
    "chromium.form_history"
    "chromium.history"
    "chromium.passwords"
    "epiphany.cache"
    "epiphany.passwords"
    "firefox.cache"
    "firefox.forms"
    "firefox.passwords"
    "firefox.url_history"
    "google_chrome.cache"
    "google_chrome.form_history"
    "google_chrome.history"
    "opera.cache"
    "opera.form_history"
    "opera.history"
    "palemoon.cache"
    "palemoon.forms"
    "palemoon.passwords"
    "palemoon.url_history"
    "waterfox.cache"
    "waterfox.forms"
    "waterfox.passwords"
    "waterfox.url_history"
  ] ++ lib.optionals cfg.withChatCleanup [
    "discord.cache"
    "discord.history"
    "skype.chat_logs"
    "skype.installers"
    "slack.cache"
    "slack.cookies"
    "slack.history"
    "slack.vacuum"
    "thunderbird.cache"
    "thunderbird.cookies"
    "thunderbird.index"
    "thunderbird.passwords"
    "thunderbird.sessionjson"
  ];
in
{
  options.services.bleachbit = {
    enable = lib.mkEnableOption "automated cleanup with Bleachbit";
    startAt = lib.mkOption {
      type = lib.types.str;
      description = ''
        How often or when cleanup will occur. For most cases, it should be enough to clean it up once per month.

        See systemd.time(7) to see the date format.
      '';
      default = "monthly";
      example = "Fri 10:00:00";
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The derivation containing <literal>bleachbit</literal> executable.
      '';
      default = pkgs.bleachbit;
    };

    persistent = lib.mkOption {
      type = lib.types.bool;
      description =
        "Whether to enable persistence for the cleanup, allowing it to activate the next time it boots when missed.";
      default = true;
      defaultText = "true";
      example = false;
    };

    cleaners = lib.mkOption {
      type = with lib.types; listOf str;
      description = "List of cleaners to be used when cleaning.";
      default = [ ];
      example = lib.literalExpression ''
        [
          "bash.history"
          "winetricks.temporary_files"
          "wine.tmp"
          "discord.history"
          "google_earth.temporary_files"
          "google_toolbar.search_history"
          "thumbnails.cache"
          "zoom.logs"
        ]
      '';
    };

    withBrowserCleanup =
      lib.mkEnableOption "browser-related cleaners to be included in the list";

    withChatCleanup =
      lib.mkEnableOption "communication apps-related cleaners to be included";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.bleachbit-cleanup = {
      Unit = {
        Description = "Periodic cleaning with Bleachbit";
        Documentation = [ "man:bleachbit(1)" "https://www.bleachbit.org" ];
      };

      Service.ExecStart = ''
        ${cfg.package}/bin/bleachbit --clean ${lib.escapeShellArgs cleaners}
      '';
    };

    systemd.user.timers.bleachbit-cleanup = {
      Unit = {
        Description = "Periodic cleaning with Bleachbit";
        Documentation = [ "man:bleachbit(1)" "https://www.bleachbit.org" ];
        PartOf = [ "default.target" ];
      };

      Install.WantedBy = [ "timers.target" ];

      Timer = {
        OnCalendar = cfg.startAt;
        Persistent = cfg.persistent;
      };
    };
  };
}
