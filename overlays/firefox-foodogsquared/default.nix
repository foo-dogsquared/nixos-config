# My personalized Firefox installation.
final: prev:

{
  firefox-foodogsquared = with prev; wrapFirefox firefox-unwrapped {
    nativeMessagingHosts = [
      ff2mpv
      bukubrow
      tridactyl-native
    ];

    extraPolicies = {
      AppAutoUpdate = false;

      Containers.Default =
        let
          mkContainer = name: color: icon: {
            inherit name color icon;
          };
        in
        [
          (mkContainer "Personal" "blue" "fingerprint")
          (mkContainer "Self-hosted" "pink" "fingerprint")
          (mkContainer "Work" "red" "briefcase")
          (mkContainer "Banking" "green" "dollar")
          (mkContainer "Shopping" "pink" "cart")
          (mkContainer "Gaming" "turquoise" "chill")
        ];

      DisableAppUpdate = true;
      DisableMasterPasswordCreation = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = true;

      ExtensionSettings =
        let
          mozillaAddon = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

          # This option assumes the default installation mode is `normal_installed`.
          extensions = {
            "@contain-facebook".install_url = mozillaAddon "facebook-container";
            "@contain-google".install_url = mozillaAddon "google-container";
            "@testpilot-containers".install_url = mozillaAddon "multi-account-containers";
            "{157eb9f0-9814-4fcc-b0b7-586b3093c641}".install_url = mozillaAddon "updateswh";
            "{15bdb1ce-fa9d-4a00-b859-66c214263ac0}".install_url = mozillaAddon "get-rss-feed-url";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = mozillaAddon "bitwarden-password-manager";
              installation_mode = "force_installed";
              default_area = "navbar";
            };
            "{dedb3663-6f13-4c6c-bf0f-5bd111cb2c79}".install_url = mozillaAddon "zhongwen";
            "{ef87d84c-2127-493f-b952-5b4e744245bc}".install_url = mozillaAddon "aw-watcher-web";
            "ff2mpv@yossarian.net" = {
              install_url = mozillaAddon "ff2mpv";
              default_area = "navbar";
            };
            "FirefoxColor@mozilla.com".install_url = mozillaAddon "firefox-color";
            "firefox-translations-addon@mozilla.org".install_url = mozillaAddon "firefox-translations";
            "jid1-MnnxcxisBPnSXQ@jetpack".install_url = mozillaAddon "privacy-badger17";
            "regrets-reporter@mozillafoundation.org".install_url = mozillaAddon "regretsreporter";
            "tridactyl.vim@cmcaine.co.uk".install_url = mozillaAddon "tridactyl-vim";
            "uBlock0@raymondhill.net".install_url = mozillaAddon "ublock-origin";
            "wayback_machine@mozilla.org" = {
              install_url = mozillaAddon "wayback-machine_new";
              default_area = "navbar";
            };
            "zotero@chnm.gmu.edu".install_url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.141.xpi";
          };

          applyInstallationMode = name: value:
            lib.nameValuePair name (value //
              (lib.optionalAttrs
                (! (lib.hasAttrByPath [ "installation_mode" ] value))
                { installation_mode = "normal_installed"; }));
        in
        lib.mapAttrs' applyInstallationMode extensions;

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

  # A custom Firefox package with specific configuration intended for guest
  # environments.
  firefox-foodogsquared-guest = with prev; wrapFirefox firefox-unwrapped {
    nativeMessagingHosts = [
      tridactyl-native
    ];

    extraPolicies = {
      AppAutoUpdate = false;
      DisableAppUpdate = true;
      DisableMasterPasswordCreation = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = true;

      ExtensionSettings =
        let
          mozillaAddon = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

          # This option assumes the default installation mode is `normal_installed`.
          extensions = {
            "@contain-facebook".install_url = mozillaAddon "facebook-container";
            "@contain-google".install_url = mozillaAddon "google-container";
            "@testpilot-containers".install_url = mozillaAddon "multi-account-containers";
            "FirefoxColor@mozilla.com".install_url = mozillaAddon "firefox-color";
            "firefox-translations-addon@mozilla.org".install_url = mozillaAddon "firefox-translations";
            "jid1-MnnxcxisBPnSXQ@jetpack".install_url = mozillaAddon "privacy-badger17";
            "tridactyl.vim@cmcaine.co.uk".install_url = mozillaAddon "tridactyl-vim";
            "uBlock0@raymondhill.net".install_url = mozillaAddon "ublock-origin";
            "wayback_machine@mozilla.org" = {
              install_url = mozillaAddon "wayback-machine_new";
              default_area = "navbar";
            };
          };

          applyInstallationMode = name: value:
            lib.nameValuePair name (value //
              (lib.optionalAttrs
                (! (lib.hasAttrByPath [ "installation_mode" ] value))
                { installation_mode = "normal_installed"; }));
        in
        lib.mapAttrs' applyInstallationMode extensions;

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
}
