{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.git;
in {
  options.users.foo-dogsquared.programs.git = {
    enable = lib.mkEnableOption "foo-dogsquared's Git setup";

    instaweb.enable =
      lib.mkEnableOption "install additional files for instaweb setup";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        mergiraf # Merging giraffes are no small task.
        tea # So you don't have to see some teas, I guess.
        hut # So you don't have to see Sourcehut's brutalist design, I guess.
      ];

      # My Git credentials.
      programs.git = {
        enable = true;
        package = pkgs.gitFull;
        lfs.enable = true;
        signing.key = "4AA9CDFF7C99DFF9";
        extraConfig = {
          core.excludesFile = builtins.toString ../../config/git/ignore;

          user = {
            name = config.accounts.email.accounts.work.realName;
            email = config.accounts.email.accounts.work.address;
          };

          alias = {
            unstage = "reset HEAD --";
            quick-rebase =
              "rebase --interactive --autostash --committer-date-is-author-date";
            quick-clone =
              "clone --depth=1 --recurse-submodules --shallow-submodules";
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
            "https://git.savannah.nongnu.org/git/".insteadOf =
              [ "sv:" "savannah:" ];
          };

          pull.rebase = "interactive";

          status = {
            showPatch = true;
            showStash = true;
          };

          submodule.fetchJobs = 0;
        };
      };

      # So you don't have to use GitHub, I guess.
      programs.gh = {
        enable = true;
        extensions = with pkgs; [ gh-eco gh-dash gh-actions-cache ];

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

    (lib.mkIf cfg.instaweb.enable {
      state.ports.git-instaweb.value = 15432;

      home.packages = with pkgs; [ lighttpd ];

      programs.git.extraConfig.instaweb = {
        local = true;
        httpd = "lighttpd";
        port = config.state.ports.git-instaweb.value;
      };

      users.foo-dogsquared.programs.custom-homepage.sections.quicklinks.links =
        lib.singleton {
          text = "Current git repo";
          url = "http://localhost:${
              builtins.toString config.state.ports.git-instaweb.value
            }";
        };
    })
  ]);
}
