# It's a user that often dwells in the terminal. Mostly used in servers.
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    glances
    wireshark-cli
    bind.dnsutils
    inetutils
    iputils
    bat
    fd
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

  profiles = {
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
