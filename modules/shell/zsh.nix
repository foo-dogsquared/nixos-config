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
      autosuggestions.enable = true;
      histFile = "\$XDG_DATA_HOME/zsh/history";
      loginShellInit = "
        export ZDOTDIR=\"\$XDG_CONFIG_HOME/zsh\"
      ";

      # Adding basic version control support to the zsh prompt. 
      # https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh
      promptInit = "
        autoload -Uz vcs_info
        precmd_vcs_info() { vcs_info }
        precmd_functions+=( precmd_vcs_info )
        setopt prompt_subst
        zstyle ':vcs_info:*' formats '[%s] (%b)'
        autoload -U colors && colors
        PROMPT=\"%F%{\${fg[white]}%}%(0?.√.%?) %B%{\$fg[magenta]%}%1~%{\$reset_color%} \$vcs_info_msg_0_ $%f%b \"
        RPROMPT=\"[%D %*]\"
      ";

      syntaxHighlighting.enable = true;
    };
  };
}
