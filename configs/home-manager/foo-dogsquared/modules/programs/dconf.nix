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

    # For everything else, pls refer to the "A happy GNOME" workflow module to
    # know what workspaces has been set.
    #
    # Also, this config block comes with the following assumptions:
    #
    # * ALL workspaces has been configured with an index.
    # * The preset workspace option for the workflow module has been enabled
    # and exclusively configured around that.
    # * The default list of applications from the workflow module.
    (lib.mkIf (lib.elem "a-happy-gnome" attrs.nixosConfig.workflows.enable or []) {
      dconf.settings = {
        "org/gnome/shell/extensions/paperwm" = {
          winprops =
            let
              inherit (attrs.nixosConfig.workflows.workflows.a-happy-gnome.paperwm) workspaces;

              # A small convenience to make memorizing the index of a workspace
              # not a thing.
              wmIndexOf = name: workspaces.${name}.index.value;

              # Another small convenience for making matches with Epiphany-made PWAs.
              mkChromiumWrapperMatch = name: attr: attr // {
                wm_class = "${config.state.packages.chromiumWrapper.pname}-${name}";
              };

              winpropRules =
                lib.optionals userCfg.setups.development.enable [
                  {
                    wm_class = "org.wezfurlong.wezterm";
                    preferredWidth = "100%";
                    spaceIndex = wmIndexOf "dev";
                  }

                  (mkChromiumWrapperMatch "devdocs" {
                    spaceIndex = wmIndexOf "dev";
                  })

                  (mkChromiumWrapperMatch "gnome-devdocs" {
                    spaceIndex = wmIndexOf "dev";
                  })
                ]
                ++ lib.optionals userCfg.setups.development.creative-coding.enable [
                  {
                    wm_class = "Processing";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "scide";
                    title = "SuperCollider IDE";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "Pure Data";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "Sonic Pi";
                    spaceIndex = wmIndexOf "creative";
                  }
                ]
                ++ lib.optionals userCfg.programs.doom-emacs.enable [{
                  wm_class = "Emacs";
                  spaceIndex = wmIndexOf "research";
                }]
                ++ lib.optionals userCfg.setups.research.enable [
                  {
                    wm_class = "Zotero";
                    spaceIndex = wmIndexOf "research";
                  }

                  {
                    wm_class = "Kiwix";
                    spaceIndex = wmIndexOf "research";
                  }
                ]
                ++ lib.optionals config.suites.desktop.audio.enable [
                  {
                    wm_class = "Audacity";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "zrythm";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "Musescore4";
                    spaceIndex = wmIndexOf "creative";
                  }
                ]
                ++ lib.optionals config.suites.desktop.audio.pipewire.enable [
                  {
                    wm_class = "org.pipewire.Helvum";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "Carla2";
                    spaceIndex = wmIndexOf "creative";
                  }
                ]
                ++ lib.optionals config.suites.desktop.graphics.enable [
                  {
                    wm_class = "org.inkscape.Inkscape";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "GIMP";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "krita";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "Pureref";
                    spaceIndex = wmIndexOf "creative";
                  }

                  {
                    wm_class = "io.github.lainsce.Emulsion";
                    spaceIndex = wmIndexOf "creative";
                  }
                ]
                ++ lib.optionals userCfg.setups.desktop.enable [
                  (mkChromiumWrapperMatch "penpot" {
                    spaceIndex = wmIndexOf "creative";
                  })

                  (mkChromiumWrapperMatch "graphite" {
                    spaceIndex = wmIndexOf "creative";
                  })
                ]
                ++ lib.optionals userCfg.programs.email.thunderbird.enable [{
                  wm_class = "thunderbird";
                  preferredWidth = "100%";
                  spaceIndex = wmIndexOf "work";
                }]
                ++ lib.optionals userCfg.programs.vs-code.enable [{
                  wm_class = "Code";
                  preferredWidth = "100%";
                  spaceIndex = wmIndexOf "dev";
                }]
                ++ lib.optionals userCfg.programs.browsers.firefox.enable [{
                  wm_class = "firefox";
                  spaceIndex = wmIndexOf "media";
                }]
                ++ lib.optionals userCfg.programs.browsers.brave.enable [{
                  wm_class = "Brave";
                  spaceIndex = wmIndexOf "media";
                }]
                ++ lib.optionals userCfg.programs.browsers.google-chrome.enable [{
                  wm_class = "Google-chrome";
                  spaceIndex = wmIndexOf "media";
                }]
                ++ lib.optionals userCfg.setups.music.spotify.enable [{
                  wm_class = "Spotify";
                  spaceIndex = wmIndexOf "media";
                }]
                ++ lib.optionals userCfg.setups.business.enable [
                  (mkChromiumWrapperMatch "discord" {
                    spaceIndex = wmIndexOf "work";
                  })

                  (mkChromiumWrapperMatch "microsoft-teams" {
                    spaceIndex = wmIndexOf "work";
                  })

                  (mkChromiumWrapperMatch "zoom" {
                    spaceIndex = wmIndexOf "work";
                  })

                  (mkChromiumWrapperMatch "google-workspace" {
                    spaceIndex = wmIndexOf "work";
                  })

                  (mkChromiumWrapperMatch "messenger" {
                    spaceIndex = wmIndexOf "work";
                  })
                ];
            in
            lib.map lib.strings.toJSON winpropRules;
        };
      };
    })
  ]);
}
