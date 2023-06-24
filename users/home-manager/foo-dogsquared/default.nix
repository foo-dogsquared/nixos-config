{ config, options, lib, pkgs, ... }:

let
  ytdlpAudio = pkgs.writeScriptBin "yt-dlp-audio" ''
    ${pkgs.yt-dlp}/bin/yt-dlp --config-location "${./config/yt-dlp-audio.conf}" $@
  '';

  dotfilesAsStorePath = config.lib.file.mkOutOfStoreSymlink config.home.mutableFile."library/dotfiles".path;
  getDotfiles = path: "${dotfilesAsStorePath}/${path}";

  musicDir = config.xdg.userDirs.music;
  playlistsDir = "${musicDir}/playlists";
in
{
  home.packages = with pkgs; [
    vscodium-fhs # Visual Studio-lite and for those who suffer from Visual Studio withdrawal.
    hledger # Trying to be a good accountant.
    hledger-utils # For extra trying to be a better accountant.

    # My music-related tools.
    songrec # SHAZAM!
    ytdlpAudio # My custom script for downloading music with yt-dlp.
    picard # Graphical beets.
  ];

  fonts.fontconfig.enable = true;

  # We're disabling it since the default Atuin integration is
  # blocking the Wezterm's shell integration by fetching another
  # instance of bash-preexec.
  programs.atuin = {
    settings = {
      auto_sync = true;
      sync_address = "http://atuin.plover.foodogsquared.one";
      sync_frequency = "10m";
    };
  };

  programs.bash.sessionVariables.PATH = "${config.home.mutableFile."library/dotfiles".path}/bin\${PATH:+:$PATH}";

  # My SSH client configuration. It is encouraged to keep matches and extra
  # configurations included in a separate `config.d/` directory. This enables
  # it to easily backup the certain files which is most likely what we're
  # mostly configuring anyways.
  programs.ssh = {
    enable = true;
    includes = [ "config.d/*" ];
    extraConfig = ''
      AddKeysToAgent confirm 15m
      ForwardAgent no
    '';
  };

  # My GPG client. It has to make sure the keys are not generated and has to be
  # backed up somewhere.
  #
  # If you want to know how to manage GPG PROPERLY for the nth time, read the
  # following document:
  # https://alexcabal.com/creating-the-perfect-gpg-keypair
  programs.gpg = {
    enable = true;

    # This is just made to be a starting point, per se.
    mutableKeys = true;
    mutableTrust = true;

    settings = {
      default-key = "0xADE0C41DAB221FCC";
      keyid-format = "0xlong";
      with-fingerprint = true;
      no-comments = false;
    };
  };

  # My Git credentials.
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    userName = "Gabriel Arazas";
    userEmail = "foodogsquared@foodogsquared.one";
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

  programs.zellij.settings = {
    default_layout = "editor";
    layout_dir = "${config.xdg.configHome}/zellij/layouts";
  };

  # My music player setup, completely configured with Nix!
  programs.beets = {
    enable = true;
    settings = {
      library = "${musicDir}/library.db";
      plugins = [
        "acousticbrainz"
        "chroma"
        "edit"
        "export"
        "fetchart"
        "fromfilename"
        "fuzzy"
        "mbsync"
        "playlist"
        "scrub"
        "smartplaylist"
      ];
      ignore_hidden = true;
      directory = musicDir;
      ui.color = true;

      import = {
        move = true;
        link = false;
        resume = true;
        incremental = true;
        group_albums = true;
        log = "beets.log";
      };

      match.ignore_video_tracks = true;

      # Plugins configuration.
      fuzzy.prefix = "-";
      scrub.auto = true;
      smartplaylist = {
        relative_to = musicDir;
        playlist_dir = playlistsDir;
        playlists = [
          {
            name = "all.m3u8";
            query = "";
          }
          {
            name = "released-in-$year.m3u8";
            query = "year:2000..2023";
          }
        ];
      };
    };
  };

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-beets
      mopidy-funkwhale
      mopidy-internetarchive
      mopidy-iris
      mopidy-local
      mopidy-mpd
      mopidy-mpris
      mopidy-youtube
    ];

    settings = {
      http = {
        hostname = "0.0.0.0";
      };

      file = {
        enabled = true;
        media_dirs = [
          "$XDG_MUSIC_DIR|Music"
          "~/library/music|Library"
        ];
      };

      internetarchive = {
        enabled = true;
        browse_limit = 150;
        search_limit = 150;
        collections = [
          "fav-foo-dogsquared"
          "audio"
          "etree"
          "audio_music"
          "audio_foreign"
        ];
      };

      m3u = {
        enabled = true;
        base_dir = musicDir;
        playlists_dir = playlistsDir;
        default_encoding = "utf-8";
        default_extension = ".m3u8";
      };
    };
  };

  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = musicDir;
  };

  # My preferred file indexing service.
  services.recoll = {
    enable = true;
    startAt = "daily";
    settings = {
      topdirs = "~/Downloads ~/Documents ~/library";
      "skippedNames+" = "node_modules";

      "~/library/projects" = {
        "skippedNames+" = ".editorconfig .gitignore result flake.lock go.sum";
      };

      "~/library/projects/software" = {
        "skippedNames+" = "target result";
      };
    };
  };

  # My custom modules.
  profiles = {
    dev = {
      enable = true;
      shell.enable = true;
      extras.enable = true;
    };
    editors.emacs.enable = true;
    desktop = {
      enable = true;
      graphics.enable = true;
      audio.enable = true;
      video.enable = true;
      documents.enable = true;
    };
    research.enable = true;
  };

  services.bleachbit = {
    enable = true;
    cleaners = [
      "bash.history"
      "winetricks.temporary_files"
      "wine.tmp"
      "discord.history"
      "google_earth.temporary_files"
      "google_toolbar.search_history"
      "thumbnails.cache"
      "zoom.logs"
    ];
    withChatCleanup = true;
    withBrowserCleanup = true;
  };

  systemd.user.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };

  # WHOA! Even browsers with extensions can be declarative!
  programs.brave = {
    enable = true;
    extensions = [
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      { id = "ekhagklcjbdpajgpjgmbionohlpdbjgc"; } # Zotero connector
      { id = "jfnifeihccihocjbfcfhicmmgpjicaec"; } # GSConnect
      { id = "aapbdbdomjkkjkaonfhkkikfgjllcleb"; } # Google Translate
      { id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; } # Firenvim
      { id = "gknkbkaapnhpmkcgkmdekdffgcddoiel"; } # Open Access Button
      { id = "fpnmgdkabkmnadcjpehmlllkndpkmiak"; } # Wayback Machine
      { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GNOME Shell integration
      { id = "haebnnbpedcbhciplfhjjkbafijpncjl"; } # TinEye Reverse Image Search
      { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # Tampermonkey
      { id = "kkmlkkjojmombglmlpbpapmhcaljjkde"; } # Zhongwen
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "oldceeleldhonbafppcapldpdifcinji"; } # LanguageTool checker
    ];
  };

  home.stateVersion = "23.05";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # All of the personal configurations.
  xdg.configFile = {
    "doom".source = getDotfiles "emacs";
    "kitty".source = getDotfiles "kitty";
    "lf".source = getDotfiles "lf";
    "nvim".source = getDotfiles "nvim";
    "wezterm".source = getDotfiles "wezterm";

    "zellij/layouts".source = ./config/zellij/layouts;
  };

  # Automating some files to be fetched on activation.
  home.mutableFile = {
    # Fetching my dotfiles,...
    "library/dotfiles" = {
      url = "https://github.com/foo-dogsquared/dotfiles.git";
      type = "git";
    };

    # ...Doom Emacs,...
    "${config.xdg.configHome}/emacs" = {
      url = "https://github.com/doomemacs/doomemacs.git";
      type = "git";
      extraArgs = [ "--depth" "1" ];
    };

    # ...and my custom theme to be a showoff.
    "${config.xdg.dataHome}/base16/bark-on-a-tree" = {
      url = "https://github.com/foo-dogsquared/base16-bark-on-a-tree-scheme.git";
      type = "git";
    };
  };

  systemd.user.services.fetch-mutable-files = {
    Service.ExecStartPost =
      let
        script = pkgs.writeShellScript "post-fetch-mutable-files" ''
          # Automate installation of Doom Emacs.
          ${config.xdg.configHome}/emacs/bin/doom install --no-config --no-fonts --install --force
          ${config.xdg.configHome}/emacs/bin/doom sync
        '';
      in
      builtins.toString script;
  };
}
