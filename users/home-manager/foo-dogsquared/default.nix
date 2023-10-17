{ config, lib, pkgs, ... }:

let
  dotfilesAsStorePath = config.lib.file.mkOutOfStoreSymlink config.home.mutableFile."library/dotfiles".path;
  getDotfiles = path: "${dotfilesAsStorePath}/${path}";
in
{
  imports = [
    ./modules/browser.nix
    ./modules/email.nix
    ./modules/keys.nix
    ./modules/git.nix
    ./modules/music.nix
  ];

  # The keyfile required to decrypt the secrets.
  sops.age.keyFile = "${config.xdg.configHome}/age/user";

  sops.secrets = lib.getSecrets ./secrets/secrets.yaml {
    davfs2-credentials = {
      path = "${config.home.homeDirectory}/.davfs2/davfs2.conf";
    };
  };

  # Set nixpkgs config both outside and inside of home-manager.
  nixpkgs.config = import ./config/nixpkgs/config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./config/nixpkgs/config.nix;

  home.packages = with pkgs; [
    hledger # Trying to be a good accountant.

    # For now, it is not possible to easily play YouTube playlists until it
    # is fixed in mpv (or yt-dlp). Ideally, this would be a Python script
    # but I don't know jack using yt-dlp as a Python module.
    (pkgs.writeShellApplication {
      name = "play-mpv-playlist-from-youtube-playlist";
      runtimeInputs = with pkgs; [
        config.programs.mpv.package
        yt-dlp
      ];
      text = ''
        yt-dlp --print id "$1" \
          | xargs -I{} echo "https://www.youtube.com/watch?v={}" \
          | mpv --playlist=-
      '';
    })
  ];

  fonts.fontconfig.enable = true;

  programs.atuin = {
    settings = {
      auto_sync = true;
      sync_address = "http://atuin.plover.foodogsquared.one";
      sync_frequency = "10m";
    };
  };

  home.sessionVariables.PATH = "${config.home.mutableFile."library/dotfiles".path}/bin\${PATH:+:$PATH}";

  # Making my favorite terminal multiplexer right now.
  programs.zellij.settings = {
    default_layout = "editor";
    layout_dir = builtins.toString ./config/zellij/layouts;
  };

  # Self-inflicted telemetry.
  services.activitywatch = {
    enable = true;
    watchers = {
      aw-watcher-afk.package = pkgs.activitywatch;
      aw-watcher-window.package = pkgs.activitywatch;
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
      shaders.enable = true;
    };
    editors = {
      emacs.enable = true;
      vscode.enable = true;
    };
    desktop = {
      enable = true;
      graphics.enable = true;
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
      "vim.history"
    ];
    withChatCleanup = true;
    withBrowserCleanup = true;
    persistent = true;
  };

  systemd.user.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };

  home.stateVersion = "23.05";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # All of the personal configurations.
  xdg.configFile = {
    distrobox.source = ./config/distrobox;
    doom.source = getDotfiles "emacs";
    kanidm.source = ./config/kanidm;
    kitty.source = getDotfiles "kitty";
    nvim.source = getDotfiles "nvim";
    nyxt.source = getDotfiles "nyxt";
    wezterm.source = getDotfiles "wezterm";
  };

  # Automating some files to be fetched on activation.
  home.mutableFile = {
    # Fetching my dotfiles,...
    "library/dotfiles" = {
      url = "https://github.com/foo-dogsquared/dotfiles.git";
      type = "git";
    };

    # ...my gopass secrets,...
    ".local/share/gopass/stores/personal" = {
      url = "gitea@code.foodogsquared.one:foodogsquared/gopass-secrets-personal.git";
      type = "gopass";
    };

    # ...and my custom theme to be a showoff.
    "${config.xdg.dataHome}/base16/bark-on-a-tree" = {
      url = "https://github.com/foo-dogsquared/base16-bark-on-a-tree-scheme.git";
      type = "git";
    };
  };
}
