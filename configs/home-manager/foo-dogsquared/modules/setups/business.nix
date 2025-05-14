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
      libreoffice
    ];

    wrapper-manager.packages.web-apps.wrappers = lib.mkIf userCfg.programs.browsers.google-chrome.enable (
      let
        inherit (foodogsquaredLib.wrapper-manager) wrapChromiumWebApp commonChromiumFlags;

        chromiumPackage = config.state.packages.chromiumWrapper;

        mkFlags = name: commonChromiumFlags ++ [
          "--user-data-dir=${config.xdg.configHome}/${chromiumPackage.pname}-${name}"
        ];
      in {
        google-workspace = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "google-workspace";
          url = "https://workspace.google.com";
          imageHash = "sha512-fdbTvnDTU7DQLSGth8hcsnTNWnBK1qc8Rvmak4oaOE+35YTJ9G8q+BdTqoYxUBxq9Dv9TkAB8Vu7UKjZL1GMcQ==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "Google Workspace";
            genericName = "Cloud Software Suite";
            comment = "Collection of Google cloud tools";
            keywords = [
              "Microsoft 365"
              "Google Docs"
              "Google Drive"
              "Google Calendar"
              "Google Sheets"
              "Gmail"
            ];
          };
        };

        microsoft-teams = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "microsoft-teams";
          url = "https://teams.microsoft.com";
          imageHash = "sha512-p71hFz3xGNCThfzgA00icEpmH8XKeRHLxwIwDruiixBmwFa/LbCkzwrkXZS4xntPrysObCsM7L0vvWl6Iq1ZAA==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "Microsoft Teams";
            genericName = "Video Conferencing";
            comment = "Video conferencing software";
            keywords = [ "Zoom" "Jitsi" "Work Chat" ];
          };
        };

        messenger = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "messenger";
          url = "https://www.messenger.com";
          imageHash = "sha512-3rbCuiW14TVu8G+VU7hEDsmW4Q7XTx6ZLeEeFtY3XUB9ylzkNSJPwz6U8EiA5vOF1f6qeO4RVWVi8n5jibPouQ==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "Messenger";
            genericName = "Instant Messaging Client";
            comment = "Instant messaging network";
            keywords = [
              "Facebook Messenger"
              "Meta Messenger"
              "Chat"
            ];
            mimeTypes = [ "x-scheme-handler/fb-messenger" ];
          };
        };

        discord = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "discord";
          url = "https://app.discord.com";
          imageHash = "sha512-A3HStENdfTG1IA5j5nCebKmQkJaKIC5Rp2NGt0ba/a3aUriVrBFZYcYmLmwDY8F98zCKyazBvnCGz9Z5/yfvUw==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "Discord";
            genericName = "Group Messaging Client";
            comment = "Group text and voice messaging";
            keywords = [
              "Chat"
              "Instant Messaging"
              "Video Conferencing"
              "Video Calls"
              "Audio Calls"
            ];
          };
        };

        zoom = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "zoom";
          url = "https://zoom.us";
          imageHash = "sha512-l0XEVskMHJXBEdqqZBkDTgGp+F50ux22d1KHH63/Bu83awQP4v80/p3Csuiz4IfIowEu27nucDkIg/nmLotvhQ==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "Zoom";
            genericName = "Video Conferencing";
            comment = "Video conferencing";
            keywords = [
              "Audio Calls"
              "Video Calls"
              "Work Chat"
            ];
          };
        };
      }
    );
  };
}
