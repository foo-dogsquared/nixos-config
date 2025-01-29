# This is mostly just the same as the Alice user except it used for installers.
# It should be niiiiiiiiiice enough for the usual cases, you feel me.
{ config, lib, pkgs, ... }:

{
  imports = [ ./modules ];

  users.nixos.programs.terminal-multiplexer.enable = true;

  suites = {
    dev = {
      enable = true;
      shell.enable = true;
    };
    editors.neovim.enable = true;
  };

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };

  # My user shell of choice because I'm not a hipster.
  programs.bash = {
    enable = true;
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    historyIgnore = [ "cd" "exit" "lf" "ls" "nvim" ];
  };

  home.stateVersion = "23.11";
}
