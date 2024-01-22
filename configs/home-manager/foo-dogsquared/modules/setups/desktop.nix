# Makes you infinitesimally productive.
{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.desktop;
in
{
  options.users.foo-dogsquared.setups.desktop.enable =
    lib.mkEnableOption "a set of usual desktop productivity services";

  config = lib.mkIf cfg.enable {
    # Install all of the desktop stuff.
    suites.desktop = {
      enable = true;
      audio.enable = true;
      audio.pipewire.enable = true;
      graphics.enable = true;
      video.enable = true;
      documents.enable = true;
    };

    # Make it rain with fonts.
    fonts.fontconfig.enable = true;

    # Forcibly set the user directories.
    xdg.userDirs.enable = true;

    # Self-inflicted telemetry.
    services.activitywatch = {
      enable = true;
      watchers = {
        aw-watcher-afk.package = pkgs.activitywatch;
        aw-watcher-window.package = pkgs.activitywatch;
      };
    };

    # Clean up your mess
    services.bleachbit = {
      enable = true;
      cleaners = [
        "winetricks.temporary_files"
        "wine.tmp"
        "discord.history"
        "google_earth.temporary_files"
        "google_toolbar.search_history"
        "thumbnails.cache"
        "zoom.logs"
        "vim.history"
      ];
      withChatCleanup = true;
      withBrowserCleanup = true;
    };

    # My preferred file indexing service.
    services.recoll = {
      enable = true;
      startAt = "daily";
      settings = {
        topdirs = "~/Downloads ~/Documents ~/library";
        "skippedNames+" = "node_modules";

        "~/library/projects" = {
          "skippedNames+" = ".editorconfig .gitignore result flake.lock go.sum";
        };

        "~/library/projects/software" = {
          "skippedNames+" = "target result";
        };
      };
    };
  };
}
