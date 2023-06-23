# Arsenal for development (which is rare nowadays). ;p
# If you're looking for text editors, go to `./editors.nix`.
{ config, options, lib, pkgs, ... }:

let cfg = config.profiles.dev;
in {
  options.profiles.dev = {
    enable =
      lib.mkEnableOption "foo-dogsquared's user-specific development setup";
    shell.enable =
      lib.mkEnableOption "configuration of foo-dogsquared's shell of choice";
    extras.enable = lib.mkEnableOption "additional tools for development stuff";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      home.packages = with pkgs; [
        dasel # Universal version of jq.
        gopass # An improved version of the password manager for hipsters.
        lf # File manager in the terminal, really.
        moar # More 'more'.
        perl534Packages.vidir # Bulk rename for your organizing needs in the terminal.
        tealdeer # An easy cop-out for basic help.

        # Coreutils replacement.
        fd # Oh nice, a more reliable `find`.
        ripgrep # On nice, a more reliable `grep`.
        exa # Oh nice, a shinier `ls`.
      ];

      # Git interface for the lazy who cannot be asked to add hunks properly.
      programs.lazygit = {
        enable = true;
        settings = {
          gui = {
            expandFocusedSidePanel = true;
            showBottomLine = false;
            skipRewordInEditorWarning = true;
            theme = {
              selectedLineBgColor = [ "reverse" ];
              selectedRangeBgColor = [ "reverse" ];
            };
          };
          notARepository = "skip";
        };
      };

      # A fuzzy finder that enables fuzzy finding not furry finding, a common misconception.
      programs.fzf = let
        fd = "${lib.getBin pkgs.fd}/bin/fd";
      in {
        enable = true;
        changeDirWidgetCommand = "${fd} --type d";
        defaultCommand = "${fd} --type f";
      };

      # dog > sky dog > cat.
      programs.bat = {
        enable = true;
        config = {
          pager = "${lib.getBin pkgs.moar}/bin/moar";
          theme = "base16";
          style = "plain";
        };
      };

      # Modern tmux? Yeah, modern tmux! For layout configurations, they are
      # more individualized so just set your home-manager users individually
      # with those. pls?
      programs.zellij = {
        enable = true;
        settings = {
          mouse_mode = false;
          copy_on_select = false;
          pane_frames = false;
        };
      };
    })

    (lib.mkIf cfg.shell.enable {
      programs.bash = {
        enable = true;
        historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
        historyIgnore = [
          "cd"
          "exit"
          "lf"
          "ls"
          "nvim"
        ];
        bashrcExtra = ''
          function f() {
            dir=''${1:-$PWD}
            dest=$(${pkgs.fd}/bin/fd --type directory --ignore-vcs --base-directory "$dir" \
              | ${pkgs.fzf}/bin/fzf --prompt "Go to directory ")
            destPrime=$(${pkgs.coreutils}/bin/realpath --canonicalize-existing --logical "$dir/$dest")

            [ "$dest" ] && cd "$destPrime"
          }

          function fh() {
            dir=''${1:-$PWD}
            dest=$(${pkgs.fd}/bin/fd --type directory --hidden --ignore-vcs --base-directory "$dir" \
              | ${pkgs.fzf}/bin/fzf --prompt "Go to directory ")
            destPrime=$(${pkgs.coreutils}/bin/realpath --canonicalize-existing --logical "$dir/$dest")

            [ "$dest" ] && cd "$destPrime"
          }

          function ff() {
            dir=''${1:-$PWD}
            dest=$(${pkgs.fd}/bin/fd --ignore-vcs --base-directory "$dir" \
              | ${pkgs.fzf}/bin/fzf --prompt "Open file ")
            destPrime=$(${pkgs.coreutils}/bin/realpath --canonicalize-existing --logical "$dir/$dest")

            if [ -d "$destPrime" ]; then
              [ "$dest" ] && cd "$destPrime";
            else
              [ "$dest" ] && ${pkgs.xdg-utils}/bin/xdg-open "$destPrime";
            fi
          }

          function ffh() {
            dir=''${1:-$PWD}
            dest=$(${pkgs.fd}/bin/fd --hidden --ignore-vcs --base-directory "$dir" \
              | ${pkgs.fzf}/bin/fzf --prompt "Open file ")
            destPrime=$(${pkgs.coreutils}/bin/realpath --canonicalize-existing --logical "$dir/$dest")

            if [ -d "$destPrime" ]; then
              [ "$dest" ] && cd "$destPrime";
            else
              [ "$dest" ] && ${pkgs.xdg-utils}/bin/xdg-open "$destPrime";
            fi
          }

          function fm() {
            ${pkgs.man}/bin/man -k . \
              | ${pkgs.fzf}/bin/fzf --multi --prompt "Open manpage(s) " \
              | ${pkgs.gawk}/bin/awk '{ print $1 "." gensub(/[()]/, "", "g", $2) }' \
              | ${pkgs.findutils}/bin/xargs man
          }
        '';
      };

      # Supercharging your shell history. Just don't forget to flush them out
      # before doing questionable things.
      programs.atuin = {
        enable = true;
        settings = {
          search_mode = "fuzzy";
          filter_mode = "global";
        };
      };

      # virtualenv but for anything else.
      programs.direnv = {
        enable = true;
        config.global = {
          load_dotenv = true;
          strict_env = true;
        };
        nix-direnv.enable = true;
      };

      # Learn teleportation in the filesystem.
      programs.zoxide.enable = true;

      # Some lazy bastard's shell prompt configuration.
      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          hostname = {
            ssh_only = false;
            trim_at = "";
          };
        };
      };
    })

    (lib.mkIf cfg.extras.enable {
      home.packages = with pkgs; [
        act # Test your CI without embarrassing yourself repeatedly pushing into GitHub repos.
        github-cli # So you don't have to use much of GitHub on the site, I guess.
        hut # So you don't have to see much of Sourcehut's brutalist design, I guess.
        hyperfine # Making sure your apps are not just fine but REEEEEEAAAAALY fine.
        irssi # Communicate in the terminal like a normal person.
        license-cli # A nice generator template for license files.
        tree-sitter # The modern way of text highlighting.
        treefmt # I like the tagline of this tool: "One CLI for formatting your code tree." (It rhymes somewhat.)
        zenith # Very fanciful system dashboard.
      ];
    })
  ]);
}
