{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "cookies-txt" = buildFirefoxXpiAddon {
      pname = "cookies-txt";
      version = "0.8";
      addonId = "{12cf650b-1822-40aa-bff0-996df6948878}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4451023/cookies_txt-0.8.xpi";
      sha256 = "0cfa85e4f1defc0f0e72c4b7a26372d7890d52780e555b868ef4a3759d7bc3ec";
      meta = with lib;
      {
        description = "Exports all cookies to a Netscape HTTP Cookie File, as used by curl, wget, and youtube-dl, among others.";
        license = licenses.gpl3;
        mozPermissions = [
          "cookies"
          "downloads"
          "contextualIdentities"
          "<all_urls>"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "extended-color-management" = buildFirefoxXpiAddon {
      pname = "extended-color-management";
      version = "1.1.1";
      addonId = "{816dd215-0e91-4621-9d89-3bac78798e6f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3966904/extended_color_management-1.1.1.xpi";
      sha256 = "8b09d9fb312635c428571bd74beacf67e426089ebc812c7f39e9c3b4dad05a0b";
      meta = with lib;
      {
        description = "Ever wish that Firefox didn't use color management when viewing images or video? Turn it off easily with this add-on.";
        license = licenses.mpl20;
        mozPermissions = [
          "browserSettings"
          "notifications"
          "storage"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "get-rss-feed-url" = buildFirefoxXpiAddon {
      pname = "get-rss-feed-url";
      version = "2.2";
      addonId = "{15bdb1ce-fa9d-4a00-b859-66c214263ac0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3990496/get_rss_feed_url-2.2.xpi";
      sha256 = "c332726405c6e976b19fc41bfb3ce70fa4380aaf33f179f324b67cb6fc13b7d0";
      meta = with lib;
      {
        homepage = "https://github.com/shevabam/get-rss-feed-url-extension";
        description = "Retrieve RSS feeds URLs from a WebSite. Now in Firefox!";
        license = licenses.mit;
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "notifications"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "google-container" = buildFirefoxXpiAddon {
      pname = "google-container";
      version = "1.5.4";
      addonId = "@contain-google";
      url = "https://addons.mozilla.org/firefox/downloads/file/3736912/google_container-1.5.4.xpi";
      sha256 = "47a7c0e85468332a0d949928d8b74376192cde4abaa14280002b3aca4ec814d0";
      meta = with lib;
      {
        homepage = "https://github.com/containers-everywhere/contain-google";
        description = "THIS IS NOT AN OFFICIAL ADDON FROM MOZILLA!\nIt is a fork of the Facebook Container addon.\n\nPrevent Google from tracking you around the web. The Google Container extension helps you take control and isolate your web activity from Google.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "contextualIdentities"
          "cookies"
          "management"
          "tabs"
          "webRequestBlocking"
          "webRequest"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "microsoft-container" = buildFirefoxXpiAddon {
      pname = "microsoft-container";
      version = "1.0.4";
      addonId = "@contain-microsoft";
      url = "https://addons.mozilla.org/firefox/downloads/file/3711415/microsoft_container-1.0.4.xpi";
      sha256 = "8780c9edcfa77a9f3eaa7da228a351400c42a884fec732cafc316e07f55018d3";
      meta = with lib;
      {
        homepage = "https://github.com/kouassi-goli/contain-microsoft";
        description = "This add-on is an unofficial fork of Mozilla's Facebook Container designed for Microsoft. \n Microsoft Container isolates your Microsoft activity from the rest of your web activity and prevent Microsoft from tracking you outside of the its website.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "contextualIdentities"
          "cookies"
          "management"
          "tabs"
          "webRequestBlocking"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "open-access-helper" = buildFirefoxXpiAddon {
      pname = "open-access-helper";
      version = "2025.3";
      addonId = "info@oahelper.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4429185/open_access_helper-2025.3.xpi";
      sha256 = "3668da1fef0b980c903ed05f7f06b23e86862b168bb83fa5b3fd5a44e124016c";
      meta = with lib;
      {
        homepage = "https://www.oahelper.org";
        description = "Effortless legal access to full text scholarly articles: \r\nOpen Access Helper will help you identify legal open access copies of academic articles, using unpaywall.org and core.ac.uk";
        mozPermissions = [
          "tabs"
          "storage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "*://*/*"
          "https://www.oahelper.org/backend/institutes/"
        ];
        platforms = platforms.all;
      };
    };
    "regretsreporter" = buildFirefoxXpiAddon {
      pname = "regretsreporter";
      version = "2.1.2";
      addonId = "regrets-reporter@mozillafoundation.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4049907/regretsreporter-2.1.2.xpi";
      sha256 = "6916bcba2c479b209510509aca304f35cf68bafbdde852511a98e501c99e77e0";
      meta = with lib;
      {
        homepage = "https://foundation.mozilla.org/regrets-reporter";
        description = "The RegretsReporter browser extension, built by the nonprofit Mozilla, helps you take control of your YouTube recommendations.";
        license = licenses.mpl20;
        mozPermissions = [
          "*://*.youtube.com/*"
          "https://incoming.telemetry.mozilla.org/*"
          "storage"
          "alarms"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "rsshub-radar" = buildFirefoxXpiAddon {
      pname = "rsshub-radar";
      version = "2.1.0";
      addonId = "i@diygod.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4433666/rsshub_radar-2.1.0.xpi";
      sha256 = "2a373e95677e5252f9819e636d955b1ad81e593ac638dbd7db317c4f2889b5b7";
      meta = with lib;
      {
        homepage = "https://github.com/DIYgod/RSSHub-Radar";
        description = "Easily find and subscribe to RSS and RSSHub.";
        mozPermissions = [ "storage" "tabs" "offscreen" "alarms" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "simple-translate" = buildFirefoxXpiAddon {
      pname = "simple-translate";
      version = "3.0.0";
      addonId = "simple-translate@sienori";
      url = "https://addons.mozilla.org/firefox/downloads/file/4286113/simple_translate-3.0.0.xpi";
      sha256 = "c9e36d1d8e32a223da367bdc83133f2436103eb5f16460c7cce2096376e78b68";
      meta = with lib;
      {
        homepage = "https://simple-translate.sienori.com";
        description = "Quickly translate selected or typed text on web pages. Supports Google Translate and DeepL API.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "sourcegraph-for-firefox" = buildFirefoxXpiAddon {
      pname = "sourcegraph-for-firefox";
      version = "23.4.14.1343";
      addonId = "sourcegraph-for-firefox@sourcegraph.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4097469/sourcegraph_for_firefox-23.4.14.1343.xpi";
      sha256 = "fa02236d75a82a7c47dabd0272b77dd9a74e8069563415a7b8b2b9d37c36d20b";
      meta = with lib;
      {
        description = "Adds code intelligence to GitHub, GitLab, Bitbucket Server, and Phabricator: hovers, definitions, references. Supports 20+ languages.";
        mozPermissions = [
          "activeTab"
          "storage"
          "contextMenus"
          "https://github.com/*"
          "https://sourcegraph.com/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "tineye-reverse-image-search" = buildFirefoxXpiAddon {
      pname = "tineye-reverse-image-search";
      version = "2.0.9";
      addonId = "tineye@ideeinc.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4452436/tineye_reverse_image_search-2.0.9.xpi";
      sha256 = "6693b267ca060df38112b3a7214932abfbd07424f7db235eba6e3752cbd5c297";
      meta = with lib;
      {
        homepage = "https://tineye.com/";
        description = "Click on any image on the web to search for it on TinEye. Recommended by Firefox! \r\nDiscover where an image came from, see how it is being used, check if modified versions exist or locate high resolution versions. Made with love by the TinEye team.";
        license = licenses.mit;
        mozPermissions = [ "menus" "storage" "scripting" "activeTab" ];
        platforms = platforms.all;
      };
    };
    "tor-control" = buildFirefoxXpiAddon {
      pname = "tor-control";
      version = "0.1.5";
      addonId = "{d22a1484-dcef-44e9-ab52-80f0f4a331a3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3698582/tor_control-0.1.5.xpi";
      sha256 = "3b529ee8993e1bdb374bb8f1fb926564eb10cd4403c09bc55077a0b72f6ff937";
      meta = with lib;
      {
        homepage = "https://add0n.com/tor-control.html";
        description = "Brings the anonymity of the Tor network and modifies few settings to protect user privacy";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "proxy"
          "privacy"
          "notifications"
          "nativeMessaging"
        ];
        platforms = platforms.all;
      };
    };
    "updateswh" = buildFirefoxXpiAddon {
      pname = "updateswh";
      version = "0.6.8";
      addonId = "{157eb9f0-9814-4fcc-b0b7-586b3093c641}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4217887/updateswh-0.6.8.xpi";
      sha256 = "ad91373253a4b24b48ca8c409195bb4e3674f574e142a6fe917524823c9c9644";
      meta = with lib;
      {
        description = "Check archival state of a source code repository and propose to update it if needed.";
        license = licenses.mit;
        mozPermissions = [ "<all_urls>" "storage" "tabs" "activeTab" ];
        platforms = platforms.all;
      };
    };
    "zhongwen" = buildFirefoxXpiAddon {
      pname = "zhongwen";
      version = "5.15";
      addonId = "{dedb3663-6f13-4c6c-bf0f-5bd111cb2c79}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4215189/zhongwen-5.15.xpi";
      sha256 = "db14741def1bdfe2d4deba2e16bf55876fdc1b35a3060dabb425d08285f5d468";
      meta = with lib;
      {
        homepage = "https://github.com/cschiller/zhongwen";
        description = "Official Firefox port of the Zhongwen Chrome extension (http://github.com/cschiller/zhongwen). Translate Chinese characters by hovering over them with the mouse. Includes internal word list, links to Chinese Grammar Wiki, tone colors, and more.";
        license = licenses.gpl2;
        mozPermissions = [ "contextMenus" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
  }