# WHOA! Even browsers with extensions can be declarative!
{ config, lib, pkgs, osConfig ? { }, ... }:

{
  home.packages = with pkgs; [
    google-chrome-dev
    nyxt
  ];

  # The only browser to give me money.
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--no-default-browser-check"
      "--use-system-default-printer"
    ];
    extensions = [
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      { id = "ekhagklcjbdpajgpjgmbionohlpdbjgc"; } # Zotero connector
      { id = "jfnifeihccihocjbfcfhicmmgpjicaec"; } # GSConnect
      { id = "aapbdbdomjkkjkaonfhkkikfgjllcleb"; } # Google Translate
      { id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; } # Firenvim
      { id = "gknkbkaapnhpmkcgkmdekdffgcddoiel"; } # Open Access Button
      { id = "fpnmgdkabkmnadcjpehmlllkndpkmiak"; } # Wayback Machine
      { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GNOME Shell integration
      { id = "haebnnbpedcbhciplfhjjkbafijpncjl"; } # TinEye Reverse Image Search
      { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # Tampermonkey
      { id = "kkmlkkjojmombglmlpbpapmhcaljjkde"; } # Zhongwen
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "oldceeleldhonbafppcapldpdifcinji"; } # LanguageTool checker
      { id = "nglaklhklhcoonedhgnpgddginnjdadi"; } # ActivityWatch Web Watcher
    ];
  };

  # Despite the name, it isn't a browser for furries.
  programs.firefox = lib.mkIf (osConfig ? programs.firefox.enable && !osConfig.programs.firefox.enable) {
    enable = true;

    package = with pkgs; wrapFirefox firefox-unwrapped {
      extraPolicies = {
        AppAutoUpdate = false;
        DisableAppUpdate = true;
        DisableMasterPasswordCreation = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DontCheckDefaultBrowser = true;
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
        SanitizeOnShutdown = {
          FormData = true;
        };
        UseSystemPrintDialog = true;
      };
    };

    profiles.personal = {
      isDefault = true;

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        aw-watcher-web
        bitwarden
        facebook-container
        firefox-color
        firefox-translations
        firenvim
        languagetool
        multi-account-containers
        privacy-badger
        tampermonkey
        tridactyl
        ublock-origin
        vimium
        wayback-machine
      ] ++ (with pkgs.firefox-addons; [
        get-rss-feed-url
        regretsreporter
        simple-translate
        tineye-reverse-image-search
        updateswh
        zhongwen
        google-container
      ]);

      settings = {
        # Disable the UI tour.
        "browser.uitour.enabled" = false;

        # Don't tease me with the updates, man.
        "apps.update.auto" = false;

        # Some inconveniences of life (at least for me).
        "extensions.pocket.enabled" = false;
        "signon.rememberSignons" = false;

        # Some quality of lifes.
        "browser.search.widget.inNavBar" = true;
        "browser.search.openintab" = true;

        # Some privacy settings...
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;

        # Burn our own fingers.
        "privacy.resistFingerprinting" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.fingerprintingProtection.pbmode" = true;

        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;

        "dom.security.https_first" = true;
        "dom.security.https_first_pbm" = true;

        "privacy.firstparty.isolate" = true;
      };

      search = {
        default = "Brave";
        force = true;
        order = [
          "Brave"
          "Nix Packages"
          "Google"
        ];
        engines = {
          "Brave" = {
            urls = [{
              template = "https://search.brave.com/search";
              params = [
                { name = "type"; value = "search"; }
                { name = "q"; value = "{searchTerms}"; }
              ];
            }];

            icon = "${config.programs.brave.package}/share/icons/hicolor/64x64/apps/brave-browser.png";
            definedAliases = [ "@brave" "@b" ];
          };

          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Bing".metaData.hidden = true;
          "Google".metaData.alias = "@g";
        };
      };
    };
  };

  # Configuring Tridactyl.
  xdg.configFile.tridactyl.source = ../config/tridactyl;
}
