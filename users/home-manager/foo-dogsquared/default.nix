{ inputs, config, options, lib, pkgs, ... }:

let
  yt-dlp-for-audio-config = pkgs.writeText "yt-dlp-for-audio-config" ''
    # Don't overwrite for cautious individuals.
    --no-overwrite

    # To make sure all audio-related.
    --extract-audio
    --format bestaudio
    --audio-format opus

    --output '%(track_number,playlist_autonumber)d-%(track,title)s.%(ext)s'
    --download-archive archive

    # Add all sorts of metadata.
    --embed-thumbnail
    --add-metadata
  '';
  yt-dlp-for-audio = pkgs.writeScriptBin "yt-dlp-audio" ''
    ${pkgs.yt-dlp}/bin/yt-dlp --config-location "${yt-dlp-for-audio-config}" $@
  '';
  getDotfiles = path: "${inputs.dotfiles}/${path}";

  musicDir = config.xdg.userDirs.music;
  playlistsDir = "${musicDir}/playlists";
in {
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ncmpcpp
    vscodium-fhs
    neovim
    yt-dlp-for-audio
  ];

  fonts.fontconfig.enable = true;

  # We're disabling it since the default Atuin integration is
  # blocking the Wezterm's shell integration by fetching another
  # instance of bash-preexec.
  programs.atuin.enableBashIntegration = false;
  programs.bash.bashrcExtra = ''
    source ${pkgs.wezterm}/etc/profile.d/wezterm.sh

    if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
      eval "$(${config.programs.atuin.package}/bin/atuin init bash)"
    fi
  '';

  # My Git credentials.
  programs.git = let email = "foo.dogsquared@gmail.com"; in {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    userName = "Gabriel Arazas";
    userEmail = email;
    signing.key = "129AFC6B4ABD6B61";
    extraConfig = {
      # This is taken from the official Git book, for future references.
      sendemail = {
        smtpserver = "smtp.gmail.com";
        smtpencryption = "tls";
        smtpserverport = 587;
        smtpuser = email;
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

  # My music player setup, completely configured with Nix!
  programs.beets = {
    enable = true;
    settings = {
      library = "${musicDir}/library.db";
      plugins = [
        "acousticbrainz"
        "chroma"
        "deezer"
        "edit"
        "export"
        "fuzzy"
        "playlist"
        "scrub"
        "smartplaylist"
        "spotify"
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

      match = {
        required = "year label";
        ignore_video_tracks = true;
      };

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
      multimedia.enable = true;
    };
    research.enable = true;
  };

  services.bleachbit = {
    enable = true;
    withChatCleanup = true;
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
      { id = "aapbdbdomjkkjkaonfhkkikfgjllcleb"; } # Google Translate (yes, I'm disappointed in myself)
      { id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; } # Firenvim
      { id = "gknkbkaapnhpmkcgkmdekdffgcddoiel"; } # Open Access Button
      { id = "fpnmgdkabkmnadcjpehmlllkndpkmiak"; } # Wayback Machine
      { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GNOME Shell integration
    ];
  };

  home.stateVersion = "22.11";

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
  };
}
