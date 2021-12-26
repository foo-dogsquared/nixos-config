# Arsenal for development (which is rare nowadays). ;p
# If you're looking for text editors, go to `./editors.nix`.
{ config, options, lib, pkgs, ... }:

let cfg = config.modules.dev;
in {
  options.modules.dev = {
    enable =
      lib.mkEnableOption "foo-dogsquared's user-specific development setup";
    shell.enable =
      lib.mkEnableOption "configuration of foo-dogsquared's shell of choice";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      home.packages = with pkgs; [
        lazygit # Git interface for the lazy.
        github-cli # So you don't have to use much of GitHub on the site, I guess.
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
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      programs.zoxide.enable = true;
      programs.starship = {
        enable = true;
        settings = { add_newline = false; };
      };
    })
  ]);
}
