{ config, lib, pkgs, ... }:

{
  build.variant = "shell";
  locale.enable = true;

  wrappers.tmux = {
    wraparound.variant = "boxxy";
    wraparound.subwrapper.arg0 = lib.getExe' pkgs.tmux "tmux";
    wraparound.boxxy.rules = {
      "~/.config/tmux/tmux.conf".source = "~/.tmux.conf";
    };
  };

  wrappers.zellij = {
    wraparound.variant = "boxxy";
    wraparound.subwrapper.arg0 = lib.getExe' pkgs.zellij "zellij";
    wraparound.boxxy.rules = {
      "$XDG_CONFIG_HOME/zellij/hello.kdl".source =
        "$XDG_CONFIG_HOME/zellij/config.kdl";
    };
  };
}
