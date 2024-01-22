# It's a user that often dwells in the terminal. Mostly used in servers.
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    glances
    wireshark-cli
    jq
  ];

  # My user shell of choice because I'm not a hipster.
  programs.bash = {
    enable = true;
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    historyIgnore = [
      "cd"
      "exit"
      "lf"
      "ls"
      "nvim"
    ];
  };

  suites = {
    dev = {
      enable = true;
      shell.enable = true;
      coreutils-replacement.enable = true;
      servers.enable = true;
    };

    editors.neovim.enable = true;
  };

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };

  services.bleachbit = {
    enable = true;
    cleaners = [
      "bash.history"
      "vim.history"
    ];
    startAt = "weekly";
  };

  home.stateVersion = "23.11";
}
