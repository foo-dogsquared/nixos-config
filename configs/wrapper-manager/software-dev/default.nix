{ config, lib, pkgs, ... }:

{
  wrappers.tmux-fds.wraparound = {
    variant = "boxxy";
    subwrapper.arg0 = lib.getExe' pkgs.tmux "tmux";
    boxxy.rules."~/.config/tmux/tmux.conf".source = "~/.tmux.conf";
  };

  wrappers.zellij-fds = {
    arg0 = lib.getExe' pkgs.zellij "zellij";
    env.ZELLIJ_CONFIG_FILE.value = ./config/zellij/config.kdl;
  };
}
