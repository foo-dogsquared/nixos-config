# Browsers for your enterprise needs (seriously though, they're configured
# differently and typically for "enterprise" use cases in mind and what I mean
# "enterprise" is for all of the users which is me, myself, and I).
{ config, options, lib, pkgs, ... }:

let
  cfg = config.profiles.browsers;
in
{
  options.profiles.browsers = {
    firefox.enable = lib.mkEnableOption "Firefox and its fixed configuration";
    chromium.enable = lib.mkEnableOption "Chromium and its fixed configuration";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.chromium.enable {
      environment.systemPackages = with pkgs; [
        chromium
      ];

      programs.chromium = {
        enable = true;

        # Unlike the user-specific browser configuration, we're just
        # considering the bare minimum set of preferred extensions.
        extensions = [
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
          "jfnifeihccihocjbfcfhicmmgpjicaec" # GSConnect
          "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
          "fpnmgdkabkmnadcjpehmlllkndpkmiak" # Wayback Machine
        ];

        extraOpts = {
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          BrowserSignIn = 0;
          ColorCorrectionEnabled = true;
          CursorHighlightEnabled = true;
          PasswordManagerEnabled = false;
        };
      };
    })

    (lib.mkIf cfg.firefox.enable {
      programs.firefox = {
        enable = true;

        policies = {
          AppAutoUpdate = false;

          Containers.Default = let
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

          ExtensionSettings =
            let
              mozillaAddon = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

              # Unlike the user-specific browser configuration, we're just
              # considering the bare minimum set of preferred extensions.
              extensions = {
                "@contain-facebook".install_url = mozillaAddon "facebook-container";
                "@contain-google".install_url = mozillaAddon "google-container";
                "@testpilot-containers".install_url = mozillaAddon "multi-account-containers";
                "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                  install_url = mozillaAddon "bitwarden-password-manager";
                  installation_mode = "force_installed";
                  default_area = "navbar";
                };
                "ff2mpv@yossarian.net" = {
                  install_url = mozillaAddon "ff2mpv";
                  default_area = "navbar";
                };
                "firefox-translations-addon@mozilla.org".install_url = mozillaAddon "firefox-translations";
                "fx_cast@matt.tf".install_url = "https://github.com/hensm/fx_cast/releases/download/v0.3.1/fx_cast-0.3.1.xpi";
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

          SearchEngines = {
            Add = [
              {
                Name = "Brave";
                URLTemplate = "https://search.brave.com/search?q={searchTerms}";
                Method = "GET";
                IconURL = "https://brave.com/static-assets/images/brave-favicon.png";
                Alias = "brave";
                SuggestURLTemplate = "https://search.brave.com/api/suggest?q={searchTerms}";
              }

              {
                Name = "nixpkgs";
                URLTemplate = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
                Method = "GET";
                IconURL = "file://${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              }
            ];
            Default = "Brave";
            Remove = [ "Bing" "Amazon" "Wikipedia (en)" ];
          };

          UseSystemPrintDialog = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };

        # These are the more situational but we'll consider the most likely to
        # be used.
        nativeMessagingHosts = {
          ff2mpv = true;
          fxCast = true;
          tridactyl = true;
        };

        preferences = {
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
      };
    })
  ];
}
