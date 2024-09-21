{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.email;
in
{
  options.users.foo-dogsquared.programs.email = {
    enable = lib.mkEnableOption "foo-dogsquared's email setup";
    thunderbird.enable = lib.mkEnableOption "foo-dogsquared's Thunderbird configuration";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      accounts.email.accounts = {
        # TODO: Enable offlineimap once maildir support is stable in Thunderbird.
        personal = {
          address = "foodogsquared@foodogsquared.one";
          aliases = [
            "admin@foodogsquared.one"
            "webmaster@foodogsquared.one"
            "hostmaster@foodogsquared.one"
            "postmaster@foodogsquared.one"
          ];
          primary = true;
          realName = "Gabriel Arazas";
          userName = "foodogsquared@mailbox.org";
          signature = {
            delimiter = "--<----<---->---->--";
            text = ''
              foodogsquared at foodogsquared dot one
            '';
          };
          passwordCommand = "gopass show personal/websites/mailbox.org/foodogsquared@mailbox.org | head -n 1";

          # Set up the ingoing mails.
          imap = {
            host = "imap.mailbox.org";
            port = 993;
            tls.enable = true;
          };

          # Set up the outgoing mails.
          smtp = {
            host = "smtp.mailbox.org";
            port = 465;
            tls.enable = true;
          };

          # GPG settings... wablamo.
          gpg = {
            key = "0xADE0C41DAB221FCC";
            encryptByDefault = false;
            signByDefault = false;
          };
        };

        old_personal = {
          address = "foo.dogsquared@gmail.com";
          realName = config.accounts.email.accounts.personal.realName;
          userName = "foo.dogsquared@gmail.com";
          flavor = "gmail.com";
          passwordCommand = "gopass show personal/websites/accounts.google.com/foo.dogsquared | head -n 1";
        };
      };
    }

    (lib.mkIf cfg.thunderbird.enable {
      programs.thunderbird = {
        enable = true;
        package = pkgs.thunderbird-foodogsquared;
        profiles.personal = {
          isDefault = true;
          settings = {
            "mail.identity.default.archive_enabled" = true;
            "mail.identity.default.archive_keep_folder_structure" = true;
            "mail.identity.default.compose_html" = false;
            "mail.identity.default.protectSubject" = true;
            "mail.identity.default.reply_on_top" = 1;
            "mail.identity.default.sig_on_reply" = true;

            "mail.server.default.canDelete" = true;
          };
        };

        settings = {
          # Some general settings.
          "mail.server.default.allow_utf8_accept" = true;
          "mail.server.default.max_articles" = 1000;
          "mail.server.default.check_all_folders_for_new" = true;
          "mail.show_headers" = 1;

          # Show some metadata.
          "mailnews.headers.showMessageId" = true;
          "mailnews.headers.showOrganization" = true;
          "mailnews.headers.showReferences" = true;
          "mailnews.headers.showUserAgent" = true;

          # Sort mails and news in descending order.
          "mailnews.default_sort_order" = 2;
          "mailnews.default_news_sort_order" = 2;

          # Sort mails and news by date.
          "mailnews.default_sort_type" = 18;
          "mailnews.default_news_sort_type" = 18;

          # Sort them by the newest reply in thread.
          "mailnews.sort_threads_by_root" = true;

          # Show time. :)
          "mail.ui.display.dateformat.default" = 1;

          # Sanitize it to UTC to prevent leaking local time.
          "mail.sanitize_date_header" = true;

          # Trust positives from server spam filter.
          "mail.server.default.serverFilterName" = "SpamAssassin";
          "mail.server.default.serverFilterFlags" = 1;

          # Email composing QoL.
          "mail.identity.default.auto_quote" = true;
          "mail.identity.default.attachPgpKey" = true;

          # RSS feeds options.
          "rss.max_concurrent_feeds" = 30;
          "rss.disable_feeds_on_update_failure" = false;

          # Open web page on default browser on select.
          "rss.message.loadWebPageOnSelect" = 0;

          # Load the summary on display.
          "rss.show.summary" = 1;

          # Open the web page on new window.
          "rss.show.content-base" = 0;

          # Don't tease me with the updates, man.
          "app.update.auto" = false;

          "privacy.donottrackheader.enabled" = true;
        };
      };

      services.bleachbit.cleaners = [
        "thunderbird.cache"
        "thunderbird.cookies"
        "thunderbird.index"
        "thunderbird.passwords"
        "thunderbird.sessionjson"
        "thunderbird.vacuum"
      ];
    })
  ]);
}
