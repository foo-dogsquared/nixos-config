{ config, options, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    mpv
  ]
  # Doom Emacs dependencies.
  ++ (with pkgs; [
    git
    ripgrep
    gnutls
    emacs-all-the-icons-fonts

    # Optional dependencies.
    fd
    imagemagick
    zstd

    # Module dependencies
    # :checkers spell
    aspell
    aspellDicts.en
    aspellDicts.en-computers

    # :tools lookup
    wordnet

    # :lang org +roam2
    sqlite
  ]);

  fonts.fontconfig.enable = true;

  # My specific usual stuff.
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    userName = "foo-dogsquared";
    userEmail = "foo.dogsquared@gmail.com";
  };

  # My music player setup, completely configured with Nix!
  services.mpd = {
    enable = true;
    musicDirectory = "$HOME/library/music";
  };
  services.mpdris2.enable = true;

  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    # TODO: Add more vim-related keybindings.
    bindings = [
      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }
      { key = "J"; command = [ "select_item" "scroll_down" ]; }
      { key = "K"; command = [ "select_item" "scroll_up" ]; }
    ];
  };

  # My custom modules.
  modules = {
    i18n.enable = true;
    archiving.enable = true;
    dev = {
      enable = true;
      shell.enable = true;
    };
    desktop = {
      enable = true;
      graphics.enable = true;
      audio.enable = true;
    };
  };
}
