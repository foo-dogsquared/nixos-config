{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.research;

  # Given an attribute set of jobs that contains a list of objects with
  # their names and URL, create an attrset suitable for declaring the
  # archiving jobs of several services for `services.yt-dlp`,
  # `services.gallery-dl`, and `services.archivebox`.
  mkJobs = { extraArgs ? [ ], db }:
    let
      days = [
        "Monday"
        "Tuesday"
        "Wednesday"
        "Thursday"
        "Friday"
        "Saturday"
        "Sunday"
      ];
      categories = lib.zipListsWith (index: category: {
        inherit index;
        data = category;
      }) (lib.lists.range 1 (lib.length (lib.attrValues db)))
        (lib.mapAttrsToList (name: value: {
          inherit name;
          inherit (value) subscriptions extraArgs;
        }) db);
      jobsList = builtins.map (category:
        let jobExtraArgs = lib.attrByPath [ "data" "extraArgs" ] [ ] category;
        in {
          name = category.data.name;
          value = {
            extraArgs = extraArgs ++ jobExtraArgs;
            urls = builtins.map (subscription: subscription.url)
              category.data.subscriptions;
            startAt =
              lib.elemAt days (lib.mod category.index (lib.length days));
          };
        }) categories;
    in lib.listToAttrs jobsList;
in {
  options.users.foo-dogsquared.setups.research.enable =
    lib.mkEnableOption "foo-dogsquared's usual toolbelt for research";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      users.foo-dogsquared.programs.password-utilities.enable = lib.mkDefault true;

      state.ports.syncthing.value = 8384;

      home.packages = with pkgs; [
        anki # Rise, rinse, and repeat.
        curl # The general purpose downloader.
        fanficfare # It's for the badly written fanfics.
        gallery-dl # More potential for your image collection.
        goldendict-ng # A golden dictionary for perfecting your diction.
        internetarchive # All of the potential vintage collection of questionable materials at your fingertips.
        kiwix # Offline reader for your fanon wiki.
        localsend # Local network syncing.
        monolith # Archive webpages into a single file.
        qbittorrent # The pirate's toolkit for downloading Linux ISOs.
        sherlock # Make a profile of your *target*.
        wget # Who would've think a simple tool can be made for this purpose?
        yt-dlp # The general purpose video downloader.
        zotero # It's actually good at archiving despite not being a researcher myself.
      ];

      services.syncthing = {
        enable = true;
        extraOptions = [
          "--gui-address=http://localhost:${
            builtins.toString config.state.ports.syncthing.value
          }"
        ];
      };

      xdg.mimeApps.defaultApplications = {
        "application/vnd.anki" = [ "anki.desktop" ];
      };

      xdg.autostart.entries =
        lib.singleton (foodogsquaredLib.xdg.getXdgDesktop pkgs.zotero "zotero");

      users.foo-dogsquared.programs.custom-homepage.sections.services.links =
        lib.singleton {
          url = "http://localhost:${
              builtins.toString config.state.ports.syncthing.value
            }";
          text = "Local sync server";
        };
    }

    (lib.mkIf userCfg.programs.shell.enable {
      programs.atuin.settings.history_filter = [
        "^curl"
        "^wget"
        "^monolith"
        "^sherlock"
        "^yt-dlp"
        "^yt-dl"
        "^gallery-dl"
        "^archivebox"
        "^fanficfare"
      ];
    })
  ]);
}
