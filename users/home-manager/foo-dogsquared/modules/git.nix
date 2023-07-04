{ config, lib, pkgs, ... }:

{
  # My Git credentials.
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    userName = config.accounts.email.accounts.personal.realName;
    userEmail = config.accounts.email.accounts.personal.address;
    signing.key = "ADE0C41DAB221FCC";
    extraConfig = {
      # This is taken from the official Git book, for future references.
      sendemail = {
        smtpserver = "smtp.mailbox.org";
        smtpencryption = "tls";
        smtpserverport = 587;
        smtpuser = "foodogsquared@mailbox.org";
      };

      alias = {
        unstage = "reset HEAD --";
        quick-rebase = "rebase --interactive --autostash --committer-date-is-author-date";
      };

      init.defaultBranch = "main";

      # Shorthand for popular forges ala-Nix flake URL inputs. It's just a fun
      # little part of the config.
      url = {
        "https://github.com/".insteadOf = [ "gh:" "github:" ];
        "https://gitlab.com/".insteadOf = [ "gl:" "gitlab:" ];
        "https://gitlab.gnome.org/".insteadOf = [ "gnome:" ];
        "https://invent.kde.org/".insteadOf = [ "kde:" ];
        "https://git.sr.ht/".insteadOf = [ "sh:" "sourcehut:" ];
        "https://git.savannah.nongnu.org/git/".insteadOf = [ "sv:" "savannah:" ];
      };
    };
  };

  # My GitHub CLI setup.
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-eco
      gh-dash
    ];

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";

      aliases = {
        pc = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
