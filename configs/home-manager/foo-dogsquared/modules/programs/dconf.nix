{ config, lib, ... }:

let
  inherit (config.xdg) userDirs;
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.dconf;
in {
  options.users.foo-dogsquared.programs.dconf.enable =
    lib.mkEnableOption "dconf configuration";

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      # My GNOME Shell and programs configuration.
      "org/gnome/shell" = {
        favorite-apps = lib.optional userCfg.programs.browsers.firefox.enable
          "firefox.desktop"
          ++ lib.optional userCfg.setups.desktop.enable "thunderbird.desktop"
          ++ lib.optional userCfg.setups.development.enable
          "org.wezfurlong.wezterm.desktop"
          ++ lib.optional userCfg.programs.doom-emacs.enable "emacs.desktop"
          ++ lib.optional userCfg.programs.vs-code.enable "code.desktop";
      };

      "org/gnome/calculator" = {
        button-mode = "basic";
        show-thousands = true;
        base = 10;
        word-size = 64;
      };

      "org/freedesktop/tracker/miner/files" = {
        index-recursive-directories = [
          # We could also use the values from home-manager but just to make GNOME Settings happy.
          "&DESKTOP"
          "&DOCUMENTS"
          "&MUSIC"
          "&PICTURES"
          "&VIDEOS"
          "&PUBLIC_SHARE"

          userDirs.extraConfig.XDG_PROJECTS_DIR
        ];
      };

      "org/gnome/epiphany".homepage-url = lib.mkIf userCfg.programs.custom-homepage.enable "file://${config.xdg.dataHome}/foodogsquared/homepage/index.html";
    };
  };
}
