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
    my.packages = with pkgs; [
      aria2         # The sequel to aria(1).
      aspell        # Hunt down a spelling bee champion to come to your shell.
      bat           # cat(1) with wings.
      buku          # A developer-oriented browser-independent bookmark manager.
      exa           # ls(1) after an exodus.
      fd            # find(1) after a cognitive behavioral therapy.
      fzf           # A fuzzy finder that enables fuzzy finding not furry finding, a common misconception.
      hexyl         # Binary viewer with a cool name on the command-line.
      hledger       # Do your accountancy thing ON THE COMMAND LINE, sure why not!
      httpie        # Want a piece of the HTTP pie.
      gopass        # The improved version of Password Store which is a password manager for hipsters.
      graphviz      # The biz central for graphical flowcharts.
      maim          # A command-line interface for parsing screenshots.
      jq            # A command-line interface for parsing JSON.
      pup           # A command-line interface for parsing HTML.
      (ripgrep.override { withPCRE2 = true; })       # Super-fast full-text searcher.
      (recoll.override { withGui = false; })          # Bring the search engine to the desktop!
      sqlite        # Battle-tested cute little database that can grow into an abomination of a data spaghetti.
      tree          # I'm not a scammer, I swear.
      unzip         # Unzip what? The world may never know.
      youtube-dl    # A program that can be sued for false advertisement as you can download from other video sources.
    ];
  };
}
