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
in {
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ncmpcpp
    vscodium-fhs
    neovim
    yt-dlp-for-audio
  ];

  fonts.fontconfig.enable = true;
  programs.bash.bashrcExtra = ''
    source ${pkgs.wezterm}/etc/profile.d/wezterm.sh
  '';

  # My specific usual stuff.
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

  services.bleachbit.enable = true;

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
