{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
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
    "simple-translate" = buildFirefoxXpiAddon {
      pname = "simple-translate";
      version = "2.8.2";
      addonId = "simple-translate@sienori";
      url = "https://addons.mozilla.org/firefox/downloads/file/4165189/simple_translate-2.8.2.xpi";
      sha256 = "8e8c3af0ffadfd3ff9928355e7be2292befe6c4f0e483f7c37c2d9a34a54f345";
      meta = with lib;
      {
        homepage = "https://simple-translate.sienori.com";
        description = "Quickly translate selected or typed text on web pages. Supports Google Translate and DeepL API.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          ];
        platforms = platforms.all;
        };
      };
    "tineye-reverse-image-search" = buildFirefoxXpiAddon {
      pname = "tineye-reverse-image-search";
      version = "2.0.4";
      addonId = "tineye@ideeinc.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4074627/tineye_reverse_image_search-2.0.4.xpi";
      sha256 = "cece89c89f4480c6b69336b43c0dd2970058f2658e6cfd0160d05ba3c0cfc1b0";
      meta = with lib;
      {
        homepage = "https://tineye.com/";
        description = "Click on any image on the web to search for it on TinEye. Recommended by Firefox! \nDiscover where an image came from, see how it is being used, check if modified versions exist or locate high resolution versions. Made with love by the TinEye team.";
        license = licenses.mit;
        mozPermissions = [ "contextMenus" "storage" ];
        platforms = platforms.all;
        };
      };
    "updateswh" = buildFirefoxXpiAddon {
      pname = "updateswh";
      version = "0.6.6";
      addonId = "{157eb9f0-9814-4fcc-b0b7-586b3093c641}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4058285/updateswh-0.6.6.xpi";
      sha256 = "281f866eedec730859f65ed43ae913f140feb423dfe3c303c0a5cb7def872eaa";
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
      version = "5.14.1";
      addonId = "{dedb3663-6f13-4c6c-bf0f-5bd111cb2c79}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4060172/zhongwen-5.14.1.xpi";
      sha256 = "108a358040bfb096b600337f6699d46ce7f48f2f88f51be7e8bd3d308c59c70b";
      meta = with lib;
      {
        homepage = "https://github.com/cschiller/zhongwen";
        description = "Official Firefox port of the Zhongwen Chrome extension (<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/4d8401bdeba5d777261b82f644f164d046c1c71c9382465493a10144cbd23de0/http%3A//github.com/cschiller/zhongwen\" rel=\"nofollow\">http://github.com/cschiller/zhongwen</a>). Translate Chinese characters by hovering over them with the mouse. Includes internal word list, links to Chinese Grammar Wiki, tone colors, and more.";
        license = licenses.gpl2;
        mozPermissions = [ "contextMenus" "tabs" "<all_urls>" ];
        platforms = platforms.all;
        };
      };
    }