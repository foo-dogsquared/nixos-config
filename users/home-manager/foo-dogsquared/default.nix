{ config, options, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    borgmatic
    borgbackup
    ncmpcpp
    vscodium-fhs
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
      mopidy-mpd
      mopidy-mpris
      mopidy-local
    ];

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

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # The XDG base directories.
    documents = "$HOME/library/documents";
    music = "$HOME/library/music";
    pictures = "$HOME/library/pictures";
    templates = "$HOME/library/templates";
    videos = "$HOME/library/videos";
  };
}
