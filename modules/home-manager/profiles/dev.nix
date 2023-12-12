# Arsenal for development (which is rare nowadays). ;p
# If you're looking for text editors, go to `./editors.nix`.
{ config, lib, pkgs, ... }@attrs:

let cfg = config.profiles.dev;
in {
  options.profiles.dev = {
    enable =
      lib.mkEnableOption "foo-dogsquared's user-specific development setup";
    shell.enable =
      lib.mkEnableOption "configuration of foo-dogsquared's shell of choice";
    extras.enable = lib.mkEnableOption "additional tools for development stuff";
    shaders.enable = lib.mkEnableOption "tools for developing shaders";
    servers.enable = lib.mkEnableOption "toolkit for managing servers from your home";
    funsies.enable = lib.mkEnableOption "installation of command-line applications for funsies";
    coreutils-replacement.enable = lib.mkEnableOption "replacement of coreutils with sane default options";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      home.packages = with pkgs; [
        cookiecutter # Cookiecutter templates for your mama (which is you).
        dasel # Universal version of jq.
        gopass # An improved version of the password manager for hipsters.
        moar # More 'more'.
        perlPackages.vidir # Bulk rename for your organizing needs in the terminal.
        tealdeer # An easy cop-out for basic help.

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
      programs.fzf =
        let
          fd = "${lib.getBin pkgs.fd}/bin/fd";
        in
        {
          enable = true;
          changeDirWidgetCommand = "${fd} --type directory --unrestricted";
          defaultCommand = "${fd} --type file --hidden";
        };

      # The file manager of choice.
      programs.lf = {
        enable = true;

        keybindings = {
          "<enter>" = "shell";
          "gr" = "cd /";
        };

        settings = {
          # Aesthetics.
          color256 = true;
          dircounts = true;
          hidden = true;
          drawbox = true;
          timefmt = "2006-01-02 15:04:05";

          # Scrolling options.
          wrapscroll = true;
          scrolloff = 10;
        };

        extraConfig = ''
          cmap <tab> cmd-menu-complete
          cmap <backtab> cmd-menu-complete-back
        '';
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

      # Echolocation.
      programs.nix-index.enable = lib.mkIf (attrs ? osConfig -> !attrs.osConfig.programs.nix-index.enable) true;
    })

    (lib.mkIf cfg.shell.enable {
      # Supercharging your shell history. Just don't forget to flush them out
      # before doing questionable things.
      programs.atuin = {
        enable = true;
        flags = [ "--disable-up-arrow" ];
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

    (lib.mkIf cfg.coreutils-replacement.enable {
      home.packages = with pkgs; [
        fd # Welp, a reliable find.
      ];

      # dog > sky dog > cat.
      programs.bat = {
        enable = true;
        config = {
          pager = "${lib.getBin pkgs.moar}/bin/moar";
          theme = "base16";
          style = "plain";
        };
      };

      # Your E last to the A.
      programs.eza = {
        enable = true;
        extraOptions = [
          "--group-directories-first"
          "--header"
        ];
      };

      # RIP indeed to grep.
      programs.ripgrep = {
        enable = true;
        arguments = [
          "--max-columns-preview"
          "--colors=line:style:bold"
        ];
      };
    })

    (lib.mkIf cfg.extras.enable {
      home.packages = with pkgs; [
        act # Test your CI without embarrassing yourself repeatedly pushing into GitHub repos.
        gum # The fancy shell script toolkit.
        hyperfine # Making sure your apps are not just fine but REEEEEEAAAAALY fine.
        license-cli # A nice generator template for license files.
        quilt # Patching right up yer' alley.
        tokei # Stroking your programming ego by how many lines of C you've written.
        treefmt # I like the tagline of this tool: "One CLI for formatting your code tree." (It rhymes somewhat.)
        vhs # Declarative terminal tool demo.
        zenith # Very fanciful system dashboard.
      ];
    })

    (lib.mkIf cfg.shaders.enable {
      home.packages = with pkgs; [
        bonzomatic # Shadertoys for desktop bozos.
        shaderc # Make some seamless background loopy things.
      ];
    })

    (lib.mkIf cfg.servers.enable {
      home.packages = with pkgs; [
        bind.dnsutils # Make DNS a little less fun.
        kanidm # What is you?
        ipcalc # Calculate how many stars are there in space.
        geoip # Know where the spam came from.
        sshfs # Intrude others' home, why don't 'ya?
        whois # Doctor, are you not?
      ];
    })

    (lib.mkIf cfg.funsies.enable {
      home.packages = with pkgs; [
        fastfetch # Fetch, fast!
        asciiquarium-transparent # The closest thing to an actual aquarium (without the responsibility, of course).
        cowsay # Cow say "WHUT?"
        krabby # Kapture them Pikachus, bruh.
        lavat # Where the lava at?
      ];
    })
  ]);
}
