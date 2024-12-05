{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.research;
in
{
  options.users.foo-dogsquared.setups.research.enable =
    lib.mkEnableOption "foo-dogsquared's usual toolbelt for research";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.ports.syncthing.value = 8384;

      users.foo-dogsquared.services.archivebox.enable = true;

      home.packages = with pkgs; [
        anki # Rise, rinse, and repeat.
        curl # The general purpose downloader.
        fanficfare # It's for the badly written fanfics.
        gallery-dl # More potential for your image collection.
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
          "--gui-address=http://localhost:${builtins.toString config.state.ports.syncthing.value}"
        ];
      };

      xdg.mimeApps.defaultApplications = {
        "application/vnd.anki" = [ "anki.desktop" ];
      };

      users.foo-dogsquared.programs.custom-homepage.sections.services.links =
        lib.singleton {
          url = "http://localhost:${builtins.toString config.state.ports.syncthing.value}";
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
