# Arsenal for development (which is rare nowadays). ;p
# If you're looking for text editors, go to `./editors.nix`.
{ config, options, lib, pkgs, ... }:

let cfg = config.profiles.dev;
in {
  options.profiles.dev = {
    enable =
      lib.mkEnableOption "foo-dogsquared's user-specific development setup";
    shell.enable =
      lib.mkEnableOption "configuration of foo-dogsquared's shell of choice";
    extras.enable = lib.mkEnableOption "additional tools for development stuff";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      home.packages = with pkgs; [
        lazygit # Git interface for the lazy.
        fzf # A fuzzy finder that enables fuzzy finding not furry finding, a common misconception.
        gopass # An improved version of the password manager for hipsters.
        perl534Packages.vidir # Bulk rename for your organizing needs.
        zellij # A modern tmux?
        tealdeer # An easy cop-out for basic help.
        lf # File manager in the terminal, really.

        # Coreutils replacement.
        fd # Oh nice, a more reliable `find`.
        ripgrep # On nice, a more reliable `grep`.
        exa # Oh nice, a shinier `ls`.
        bat # dog > bat > cat
      ];
    })

    (lib.mkIf cfg.shell.enable {
      programs.atuin.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      programs.zoxide.enable = true;

      # Enable Starship prompt.
      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          hostname = {
            ssh_only = false;
            trim_at = "";
          };
        };
      };
    })

    (lib.mkIf cfg.extras.enable {
      home.packages = with pkgs; [
        tree-sitter # The modern way of text highlighting.
        hyperfine # Command-line profiling.
        github-cli # So you don't have to use much of GitHub on the site, I guess.
        hut # Easier interfacing with Sourcehut.
        act # Test your CI without embarrassing yourself pushing into upstream.
        irssi # Communicate in the terminal like a normal person.
        hexchat # Communicate on the desktop like an insane person.
      ];
    })
  ]);
}
