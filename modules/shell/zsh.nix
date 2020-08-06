# The Zoomer shell is cool for them prompts.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.shell.zsh = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  # Going to use the home-manager module for zsh since it is cool.
  config = mkIf config.modules.shell.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      dotDir = "${config.xdg.configHome}";
      history.path = "${config.xdg.dataHome}/zsh/history";
    };
  };
}
