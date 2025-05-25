# WHOA! Even browsers with extensions can be declarative!
{ config, lib, pkgs, foodogsquaredLib, ... }@attrs:

let
  inherit (foodogsquaredLib.xdg) getXdgDesktop;
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.browsers;

  commonExtensions = [
    { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
    { id = "aapbdbdomjkkjkaonfhkkikfgjllcleb"; } # Google Translate
    { id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; } # Firenvim
    { id = "haebnnbpedcbhciplfhjjkbafijpncjl"; } # TinEye Reverse Image Search
    { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # Tampermonkey
    { id = "kkmlkkjojmombglmlpbpapmhcaljjkde"; } # Zhongwen
    { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
    { id = "oldceeleldhonbafppcapldpdifcinji"; } # LanguageTool checker
  ] ++ lib.optionals config.services.activitywatch.enable [
    { id = "nglaklhklhcoonedhgnpgddginnjdadi"; } # ActivityWatch Web Watcher
  ] ++ lib.optionals (lib.elem "a-happy-gnome" attrs.nixosConfig.workflows.enable or []) [
    { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GNOME Shell integration
    { id = "jfnifeihccihocjbfcfhicmmgpjicaec"; } # GSConnect
  ] ++ lib.optionals userCfg.services.archivebox.enable [
    { id = "habonpimjphpdnmcfkaockjnffodikoj"; } # ArchiveBox Extractor
  ] ++ lib.optionals userCfg.setups.research.enable [
    { id = "gknkbkaapnhpmkcgkmdekdffgcddoiel"; } # Open Access Button
    { id = "fpnmgdkabkmnadcjpehmlllkndpkmiak"; } # Wayback Machine
    { id = "ekhagklcjbdpajgpjgmbionohlpdbjgc"; } # Zotero connector
    { id = "palihjnakafgffnompkdfgbgdbcagbko"; } # UpdateSWH
  ] ++ lib.optionals userCfg.setups.development.enable [
    { id = "dgjhfomjieaadpoljlnidmbgkdffpack"; } # Sourcegraph
  ];
in {
  options.users.foo-dogsquared.programs.browsers = {
    firefox.enable = lib.mkEnableOption "foo-dogsquared's Firefox setup";
    brave.enable = lib.mkEnableOption "foo-dogsquared's Brave setup";
    google-chrome.enable =
      lib.mkEnableOption "foo-dogsquared's Google Chrome setup";
    misc.enable =
      lib.mkEnableOption "foo-dogsquared's miscellaneous browsers setup";

    plugins.firenvim.enable = lib.mkEnableOption "setting up Firenvim";
  };

  config = lib.mkMerge [
    # The only browser to give me money.
    (lib.mkIf cfg.brave.enable {
      programs.brave = {
        enable = true;
        commandLineArgs =
          [ "--no-default-browser-check" "--use-system-default-printer" ];
        extensions = commonExtensions;
      };

      services.bleachbit.cleaners = [
        "brave.cookies"
        "brave.dom"
        "brave.form_history"
        "brave.history"
        "brave.passwords"
        "brave.session"
        "brave.sync"
        "brave.vacuum"
      ];
    })

    # Despite the name, it isn't a browser for furries.
    (lib.mkIf cfg.firefox.enable {
      programs.firefox = {
        enable = true;

        nativeMessagingHosts = with pkgs;
          [ bukubrow tridactyl-native ]
          ++ lib.optional config.programs.mpv.enable pkgs.ff2mpv;

        policies = {
          AppAutoUpdate = false;
          DisableAppUpdate = true;
          DisableMasterPasswordCreation = true;
          DisablePocket = true;
          DisableSetDesktopBackground = true;
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = true;
          FirefoxHome = {
            Highlights = false;
            Pocket = false;
            Snippets = false;
            SponsporedPocket = false;
            SponsporedTopSites = false;
          };
          NoDefaultBookmarks = true;
          OfferToSaveLoginsDefault = false;
          PasswordManagerEnabled = false;
          SanitizeOnShutdown = { FormData = true; };
          UseSystemPrintDialog = true;
        };

        profiles.personal = lib.mkMerge [
          {
            isDefault = true;

            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons;
              [
                bitwarden
                browserpass
                facebook-container
                firefox-color
                firefox-translations
                firenvim
                languagetool
                multi-account-containers
                privacy-badger
                search-by-image
                tampermonkey
                tridactyl
                ublock-origin
                vimium
                wayback-machine
              ] ++ (with pkgs.firefox-addons; [
                google-container
                microsoft-container
                regretsreporter
                simple-translate
                sourcegraph-for-firefox
                updateswh
                zhongwen
                open-access-helper
                rsshub-radar
              ]) ++ lib.optionals config.programs.mpv.enable
              (with pkgs.nur.repos.rycee.firefox-addons; [ ff2mpv ])
              ++ lib.optionals config.services.activitywatch.enable
              (with pkgs.nur.repos.rycee.firefox-addons; [ aw-watcher-web ]);

            # Much of the settings are affected by the policies set in the
            # package. See more information about them in
            # https://mozilla.github.io/policy-templates/.
            settings = lib.mkMerge [
              {
                # Disable the UI tour.
                "browser.uitour.enabled" = false;

                # Some quality of lifes.
                "browser.search.widget.inNavBar" = true;
                "browser.search.openintab" = true;

                # Some privacy settings...
                "privacy.donottrackheader.enabled" = true;

                # Burn our own fingers.
                "privacy.resistFingerprinting" = true;
                "privacy.fingerprintingProtection" = true;
                "privacy.fingerprintingProtection.pbmode" = true;

                "privacy.query_stripping.enabled" = true;
                "privacy.query_stripping.enabled.pbmode" = true;

                "dom.security.https_first" = true;
                "dom.security.https_first_pbm" = true;

                "privacy.firstparty.isolate" = true;

                # Enable them vertical bars.
                "sidebar.revamp" = true;
                "sidebar.verticalTabs" = true;
              }

              (lib.mkIf userCfg.programs.custom-homepage.enable {
                "browser.startup.homepage" = "file://${config.xdg.dataHome}/foodogsquared/homepage";
              })
            ];

            search = {
              default = "Brave";
              force = true;
              order = [ "Brave" "Nix Packages" "google" ];
              engines = {
                "Brave" = {
                  urls = lib.singleton {
                    template = "https://search.brave.com/search";
                    params = [
                      {
                        name = "type";
                        value = "search";
                      }
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  };

                  icon =
                    "${config.programs.brave.package}/share/icons/hicolor/64x64/apps/brave-browser.png";
                  definedAliases = [ "@brave" "@b" ];
                };

                "Nix Packages" = {
                  urls = lib.singleton {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  };

                  icon =
                    "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };

                "bing".metaData.hidden = true;
                "duckduckgo".metaData.hidden = true;
                "google".metaData.alias = "@g";
              };
            };
          }

          (lib.mkIf userCfg.programs.doom-emacs.enable {
            settings."network.protocol-handler.expose.org-protocol" = true;

            bookmarks = [
              {
                name = "Refer to org-roam node";
                tags = [ "org-roam" ];

                # Formatted like this for ease of modifying.
                url = lib.concatStrings [
                  "javascript:location.href="
                  "'org-protocol://roam-ref?template=r&ref='"
                  "+encodeURIComponent(location.href)"
                  "+'&title='"
                  "+encodeURIComponent(document.title)"
                  "+'&body='"
                  "+encodeURIComponent(window.getSelection())"
                ];
              }
            ];
          })
        ];

        profiles.guest = {
          search.default = "Google";
          id = 1;
        };
      };

      # Configuring Tridactyl.
      xdg.configFile."tridactyl/tridactylrc".source = pkgs.concatTextFile {
        name = "tridactyl-config";
        files = [
          ../../config/tridactyl/tridactylrc

          (pkgs.writeTextFile {
            name = "tridactyl-nix-generated";
            text =
              lib.optionalString userCfg.programs.custom-homepage.enable ''
                bind gT tabopen file://${config.xdg.dataHome}/foodogsquared/homepage/index.html
                set newtab file://${config.xdg.dataHome}/foodogsquared/homepage/index.html
              ''
              + lib.optionalString attrs.nixosConfig.services.miniflux.enable ''
                " This is to take advantage of Miniflux shortcuts.
                blacklistadd localhost:${builtins.toString attrs.nixosConfig.state.ports.miniflux.value}
              '';
          })
        ];
      };

      xdg.autostart.entries =
        lib.singleton (getXdgDesktop config.programs.firefox.package "firefox");

      # Configuring Bleachbit for Firefox cleaning.
      services.bleachbit.cleaners = [
        "firefox.backup"
        "firefox.cookies"
        "firefox.crash_reports"
        "firefox.dom"
        "firefox.forms"
        "firefox.passwords"
        "firefox.site_preferences"
        "firefox.url_history"
        "firefox.vacuum"
      ];
    })

    (lib.mkIf cfg.google-chrome.enable {
      programs.google-chrome.enable = true;

      programs.google-chrome.commandLineArgs =
        [ "--no-default-browser-check" "--use-system-default-printer" ];

      services.bleachbit.cleaners = [
        "google_chrome.cookies"
        "google_chrome.dom"
        "google_chrome.form_history"
        "google_chrome.history"
        "google_chrome.passwords"
        "google_chrome.session"
        "google_chrome.sync"
        "google_chrome.vacuum"
      ];
    })

    # Goes with whatever you want to.
    (lib.mkIf cfg.misc.enable {
      home.packages = with pkgs; [
        nyxt
        tor-browser
      ];
    })

    (lib.mkIf cfg.plugins.firenvim.enable (let
      supportedBrowsers = [ "brave" "chromium" "google-chrome" "vivaldi" ];
      enableSupportedBrowser = acc: name:
        acc // {
          programs.${name}.extensions =
            [{ id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; }];
        };
    in lib.foldl' enableSupportedBrowser { } supportedBrowsers // {
      programs.firefox.profiles.personal.extensions.packages =
        with pkgs.nur.repos.rycee.firefox-addons;
        [ firenvim ];
    }))
  ];
}
