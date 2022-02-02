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
    neovim
    borgmatic
    borgbackup
    ncmpcpp
    vscodium-fhs
    tree-sitter
    yt-dlp-for-audio
  ];

  fonts.fontconfig.enable = true;

  # My specific usual stuff.
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    userName = "Gabriel Arazas";
    userEmail = "foo.dogsquared@gmail.com";
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
      mopidy-spotify
      mopidy-youtube
    ];

    configuration = {
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

  services = {
    archivebox = {
      enable = true;
      archivePath = "%h/library/archives";
    };
    bleachbit.enable = true;
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
    ];
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
