{ config, lib, pkgs, ... }:

{
  build.isBinary = false;
  locale.enable = true;

  wrappers.tmux = {
    sandboxing.variant = "boxxy";
    sandboxing.wraparound.arg0 = lib.getExe' pkgs.tmux "tmux";
    sandboxing.boxxy.rules = {
      "~/.config/tmux/tmux.conf".source = "~/.tmux.conf";
    };
  };

  wrappers.zellij = {
    sandboxing.variant = "boxxy";
    sandboxing.wraparound.arg0 = lib.getExe' pkgs.zellij "zellij";
    sandboxing.boxxy.rules = {
      "$XDG_CONFIG_HOME/zellij/hello.kdl".source = "$XDG_CONFIG_HOME/zellij/config.kdl";
    };
  };
}
