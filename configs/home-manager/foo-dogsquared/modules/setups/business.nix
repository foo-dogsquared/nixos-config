{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.business;
in {
  options.users.foo-dogsquared.setups.business.enable =
    lib.mkEnableOption "business setup";

  config = lib.mkIf cfg.enable {
    users.foo-dogsquared.programs = {
      email = {
        enable = true;
        thunderbird.enable = true;
      };
    };

    home.packages = with pkgs; [
      libreoffice zoom-us
    ];

    wrapper-manager.packages.web-apps.wrappers = lib.mkIf userCfg.programs.browsers.google-chrome.enable (
      let
        inherit (foodogsquaredLib.wrapper-manager) wrapChromiumWebApp commonChromiumFlags;

        chromiumPackage = config.state.packages.chromiumWrapper;

        mkFlags = name: commonChromiumFlags ++ [
          "--user-data-dir=${config.xdg.configHome}/${chromiumPackage.pname}-${name}"
        ];
      in {
        google-workspace = wrapChromiumWebApp {
          inherit chromiumPackage;
          name = "Google Workspace";
          url = "https://workspace.google.com";
          imageHash = "sha512-fdbTvnDTU7DQLSGth8hcsnTNWnBK1qc8Rvmak4oaOE+35YTJ9G8q+BdTqoYxUBxq9Dv9TkAB8Vu7UKjZL1GMcQ==";
          appendArgs = mkFlags "google-workspace";
          xdg.desktopEntry.settings = {
            comment = "Collection of Google cloud tools";
            keywords = [
              "Microsoft 365"
              "Google Docs"
              "Gmail"
            ];
          };
        };

        microsoft-teams = wrapChromiumWebApp {
          inherit chromiumPackage;
          name = "Microsoft Teams";
          url = "https://teams.microsoft.com";
          imageHash = "sha512-p71hFz3xGNCThfzgA00icEpmH8XKeRHLxwIwDruiixBmwFa/LbCkzwrkXZS4xntPrysObCsM7L0vvWl6Iq1ZAA==";
          appendArgs = mkFlags "microsoft-teams";
          xdg.desktopEntry.settings = {
            comment = "Video conferencing software";
            keywords = [ "Zoom" "Jitsi" ];
          };
        };

        messenger = wrapChromiumWebApp {
          inherit chromiumPackage;
          name = "Messenger";
          url = "https://www.messenger.com";
          imageHash = "sha512-0VDdOCfJMWbC+jHz7wn7qTA0pShCydf+n9ePaFnNxyQ+1tVppaPymu4YHfGDJ3J7823GFuwa4VvkdH08suMiww==";
          appendArgs = mkFlags "messenger";
          xdg.desktopEntry.settings = {
            comment = "Instant messaging network";
            keywords = [
              "Facebook Messenger"
              "Instant Messenging"
            ];
          };
        };
      }
    );
  };
}
