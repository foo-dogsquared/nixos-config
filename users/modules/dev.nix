{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.dev;
in
  {
    options.modules.dev = {
      enable = lib.mkEnableOption "Enable my user-specific development setup.";
      shell.enable = lib.mkEnableOption "Configures my shell of choice.";
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      ({
        home.packages = with pkgs; [
          neovim # My text editor of choice.
          lazygit # Git interface for the lazy.
          fzf # A fuzzy finder that enables fuzzy finding not furry finding, a common misconception.
          gopass # An improved version of the password manager for hipsters.

          # Coreutils replacement.
          fd # Oh nice, a more reliable `find`.
          ripgrep # On nice, a more reliable `grep`.
          exa # Oh nice, a shinier `ls`.
          bat # dog > bat > cat
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        programs.zoxide.enable = true;
      })
    ]);
}
