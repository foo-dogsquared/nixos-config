# Here are the base packages for my shell workflow.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.shell.base = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.base.enable {
    home.packages = with pkgs; [
      aspell        # Want to check spelling on the command-line?
      bat           # cat(1) with wings.
      buku          # A developer-oriented browser-independent bookmark manager.
      exa           # ls(1) after an exodus.
      fd            # find(1) after a cognitive behavioral therpay.
      fzf           # A fuzzy finder, not furry finder which is a common misconception.
      hexyl         # Binary viewer on the command-line.
      gopass        # The improved version of Password Store which is a password manager for hipsters.
      maim          # A command-line interface for screenshots.
      jq            # A command-line interface for parsing JSON.
      pup           # A command-line interface for parsing HTML.
      ripgrep       # Super-fast full-text searcher.
      sqlite        # Battle-tested cute little database that can grow into an abomination of a data spaghetti.
      tree          # I'm not a scammer, I swear.
      youtube-dl    # A command-line interface for downloading videos.
    ];
  };
}
