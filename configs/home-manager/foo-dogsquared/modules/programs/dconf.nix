{ config, lib, ... }@attrs:

let
  inherit (config.xdg) userDirs;
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.dconf;
in {
  options.users.foo-dogsquared.programs.dconf.enable =
    lib.mkEnableOption "dconf configuration";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
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
    }

    (lib.mkIf (lib.elem "a-happy-gnome" attrs.nixosConfig.workflows.enable or []) {
      dconf.settings = {
        "org/gnome/shell/extensions/paperwm" = {
          winprops =
            let
              winpropRules =
                lib.optionals userCfg.setups.development.enable [{
                  wm_class = "org.wezfurlong.wezterm";
                  preferredWidth = "100%";
                  spaceIndex = 1;
                }]
                ++ lib.optionals userCfg.programs.doom-emacs.enable [{
                  wm_class = "Emacs";
                  preferredWidth = "100%";
                  spaceIndex = 2;
                }]
                ++ lib.optionals userCfg.setups.research.enable [
                  {
                    wm_class = "Zotero";
                    spaceIndex = 2;
                  }

                  {
                    wm_class = "Kiwix";
                    spaceIndex = 2;
                  }
                ]
                ++ lib.optionals userCfg.programs.browsers.firefox.enable [{
                  wm_class = "Firefox";
                  preferredWidth = "100%";
                  spaceIndex = 0;
                }]
                ++ lib.optionals userCfg.setups.music.spotify.enable [{
                  wm_class = "Spotify";
                  preferredWidth = "100%";
                  spaceIndex = 0;
                }];
            in
            lib.map lib.strings.toJSON winpropRules;
        };
      };
    })
  ]);
}
