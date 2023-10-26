{ config, lib, pkgs, ... }:

{
  # My Git credentials.
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    signing.key = "ADE0C41DAB221FCC";
    extraConfig = {
      user = {
        name = config.accounts.email.accounts.personal.realName;
        email = config.accounts.email.accounts.personal.address;
      };

      alias = {
        unstage = "reset HEAD --";
        quick-rebase = "rebase --interactive --autostash --committer-date-is-author-date";
        quick-clone = "clone --depth=1 --recurse-submodules --shallow-submodules";
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

      status = {
        showPatch = true;
        showStash = true;
      };

      submodule.fetchJobs = 0;
    };
  };

  # My GitHub CLI setup.
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-eco
      gh-dash
      gh-actions-cache
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
