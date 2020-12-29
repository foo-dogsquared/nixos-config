# The Zoomer shell is cool for them prompts.
{ config, options, lib, pkgs, ... }:

with lib;

let cfg = config.modules.shell.zsh;
in {
  options.modules.shell.zsh = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  # Going to use the home-manager module for zsh since it is cool.
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      histFile = "$XDG_DATA_HOME/zsh/history";

      interactiveShellInit = ''
        # Use lf to switch directories and bind it to ctrl-o
        lfcd () {
          tmp="$(mktemp)"
          lf -last-dir-path="$tmp" "$@"
          if [ -f "$tmp" ]; then
            dir="$(cat "$tmp")"
            rm -f "$tmp" >/dev/null
            [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
          fi
        }
        bindkey -s '^o' 'lfcd\n'
      '';

      ohMyZsh.plugins = [ "history-substring-search" ];
      syntaxHighlighting.enable = true;
    };
  };
}
