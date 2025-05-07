# Makes you infinitesimally productive.
{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.desktop;
in {
  options.users.foo-dogsquared.setups.desktop.enable =
    lib.mkEnableOption "a set of usual desktop productivity services";

  config = lib.mkIf cfg.enable {
    state.ports.activitywatch.value = 5600;

    home.packages = with pkgs; [
      bitwarden-cli bitwarden-desktop

      freecad
      kicad
      leocad
      librecad
    ];

    # users.foo-dogsquared.programs.kando.enable = true;

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
      settings.server.port = config.state.ports.activitywatch.value;
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
        "skippedNames+" = let inherit (config.state.paths) ignoreDirectories;
        in lib.concatStringsSep " " ignoreDirectories;

        "~/library/projects" = {
          "skippedNames+" = ".editorconfig .gitignore result flake.lock go.sum";
        };

        "~/library/projects/software" = { "skippedNames+" = "target result"; };
      };
    };

    # My daily digital newspaper.
    services.matcha = {
      enable = true;
      settings = {
        opml_file_path = "${config.xdg.userDirs.documents}/feeds.opml";
        markdown_dir_path = "${config.xdg.userDirs.documents}/Matcha";
      };
      startAt = "daily";
    };

    users.foo-dogsquared.programs.custom-homepage.sections.services.links =
      lib.singleton {
        url = "http://localhost:${
            builtins.toString config.state.ports.activitywatch.value
          }";
        text = "Telemetry server";
      };

    wrapper-manager.packages.web-apps.wrappers = let
      inherit (foodogsquaredLib.wrapper-manager) wrapChromiumWebApp;

      chromiumPackage = pkgs.chromium;

      # If you want to explore what them flags are doing, you can see them in
      # their codesearch at:
      # https://source.chromium.org/chromium/chromium/ (chrome_switches.cc file)
      mkFlags = name: [
        "--user-data-dir=${config.xdg.configHome}/chromium-${name}"
        "--disable-sync"
        "--no-service-autorun"
      ];
    in {
      penpot = wrapChromiumWebApp {
        name = "Penpot";
        url = "https://design.penpot.app";
        imageHash = "sha256-nE/AYk35eWSQIstZ6Bwc95I+OQ4SLjPGHIgFfoc0ilg=";
        appendArgs = mkFlags "penpot";
        xdg.desktopEntry.settings = {
          categories = [ "Graphics" ];
        };
      };

      graphite = wrapChromiumWebApp {
        name = "Graphite";
        url = "https://editor.graphite.rs";
        imageHash = "sha256-1OTwNSmvz5jve3P5Z6LcPTiW1zDI8Vqqe/i9F1DcsaA=";
        appendArgs = mkFlags "graphite";
        xdg.desktopEntry.settings = {
          categories = [ "Graphics" ];
        };
      };

      devdocs = wrapChromiumWebApp {
        name = "DevDocs";
        url = "https://devdocs.io";
        imageHash = "sha256-UfW5nGOCLuQJCSdjnV6RVFP7f6cK7KHclDuCvrfFavM=";
        appendArgs = mkFlags "devdocs";
        xdg.desktopEntry.settings = {
          categories = [ "Development" ];
        };
      };

      gnome-devdocs = wrapChromiumWebApp {
        name = "GNOME DevDocs";
        url = "https://gjs-docs.gnome.org";
        imageHash = "sha256-UfW5nGOCLuQJCSdjnV6RVFP7f6cK7KHclDuCvrfFavM=";
        appendArgs = mkFlags "gnome-devdocs";
        xdg.desktopEntry.settings = {
          categories = [ "Development" ];
        };
      };
    };
  };
}
