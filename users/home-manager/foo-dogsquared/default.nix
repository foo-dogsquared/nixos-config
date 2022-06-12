{ config, options, lib, pkgs, ... }:

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
in {
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ncmpcpp
    vscodium-fhs
    neovim
    yt-dlp-for-audio
  ];

  fonts.fontconfig.enable = true;

  # My specific usual stuff.
  programs.git = let email = "foo.dogsquared@gmail.com"; in {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    userName = "Gabriel Arazas";
    userEmail = email;
    extraConfig = {
      # This is taken from the official Git book, for future references.
      sendemail = {
        smtpserver = "smtp.gmail.com";
        smtpencryption = "tls";
        smtpserverport = 587;
        smtpuser = email;
      };
    };
  };

  # My music player setup, completely configured with Nix!
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
    };
  };

  services.recoll = {
    enable = true;
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
    i18n.enable = true;
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

  services.archivebox = {
    enable = true;
    archivePath = "%h/library/archives";
    withDependencies = true;
    webserver.enable = true;

    jobs = {
      arts = {
        links = [
          "https://www.davidrevoy.com/feed/rss"
          "https://librearts.org/index.xml"
        ];
        startAt = "weekly";
      };

      computer = {
        links = [
          "https://blog.mozilla.org/en/feed/"
          "https://distill.pub/rss.xml"
          "https://drewdevault.com/blog/index.xml"
          "https://fasterthanli.me/index.xml"
          "https://jvns.ca/atom.xml"
          "https://www.bytelab.codes/rss/"
          "https://www.collabora.com/feed"
          "https://www.jntrnr.com/atom.xml"
          "https://yosoygames.com.ar/wp/?feed=rss"
          "https://simblob.blogspot.com/feeds/posts/default"
        ];
        startAt = "daily";
      };

      projects = {
        links = [
          "https://veloren.net/rss.xml"
          "https://guix.gnu.org/feeds/blog.atom"
          "https://fedoramagazine.org/feed/"
          "https://nixos.org/blog/announcements-rss.xml"
        ];
        startAt = "*-*-1/2";
      };
    };
  };

  services.bleachbit.enable = true;

  home.sessionVariables = {
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

  programs.irssi = {
    enable = true;
    networks.liberachat = {
      nick = "foo-dogsquared";
      server = {
        address = "irc.libera.chat";
        port = 6697;
      };
      channels = {
        nixos = { };
        guix = { };
      };
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # The XDG base directories. Most of my setup with this user will be my
    # personal computer so I'll set them like so...
    documents = "$HOME/library/documents";
    music = "$HOME/library/music";
    pictures = "$HOME/library/pictures";
    templates = "$HOME/library/templates";
    videos = "$HOME/library/videos";
  };
}
