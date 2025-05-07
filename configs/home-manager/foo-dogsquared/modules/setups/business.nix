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
        inherit (foodogsquaredLib.wrapper-manager) wrapChromiumWebApp;

        chromiumPackage = config.state.packages.chromiumWrapper;

        mkFlags = name: [
          "--user-data-dir=${config.xdg.configHome}/${chromiumPackage.pname}-${name}"
          "--disable-sync"
          "--no-service-autorun"
        ];
      in {
        google-workspace = wrapChromiumWebApp {
          inherit chromiumPackage;
          name = "Google Workspace";
          url = "https://workspace.google.com";
          imageHash = "";
          appendArgs = mkFlags "google-workspace";
          xdg.desktopEntry.settings = {
            comment = "Collection of Google cloud tools";
          };
        };

        microsoft-teams = wrapChromiumWebApp {
          inherit chromiumPackage;
          name = "Microsoft Teams";
          url = "https://teams.microsoft.com";
          imageHash = "";
          appendArgs = mkFlags "microsoft-teams";
          xdg.desktopEntry.settings = {
            comment = "Video conferencing software";
          };
        };

        messenger = wrapChromiumWebApp {
          inherit chromiumPackage;
          name = "Messenger";
          url = "https://www.messenger.com";
          imageHash = "sha512-3rbCuiW14TVu8G+VU7hEDsmW4Q7XTx6ZLeEeFtY3XUB9ylzkNSJPwz6U8EiA5vOF1f6qeO4RVWVi8n5jibPouQ==";
          appendArgs = mkFlags "messenger";
          xdg.desktopEntry.settings = {
            comment = "Instant messaging network";
          };
        };
      }
    );
  };
}
