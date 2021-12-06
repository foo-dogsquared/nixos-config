# Your text editor war arsenal.
{ config, options, lib, pkgs, ... }:

let cfg = config.modules.editors;
in {
  options.modules.editors = {
    neovim.enable = lib.mkEnableOption "Enable Neovim and its components";
    emacs = {
      enable = lib.mkEnableOption "Enable Emacs and all of its components";
      doom.enable =
        lib.mkEnableOption "Enable Doom Emacs-related dependencies.";
    };
    vscode.enable = lib.mkEnableOption "Enable Visual Studio Code";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.emacs.enable {
      environment.systemPackages = with pkgs;
        [ emacs ] ++ (if cfg.emacs.doom.enable then [
          # The required depdencies.
          git
          ripgrep
          gnutls
          emacs-all-the-icons-fonts

          # Optional dependencies.
          fd
          imagemagick
          zstd

          # Module dependencies
          # :checkers spell
          aspell
          aspellDicts.en
          aspellDicts.en-computers

          # :tools lookup
          wordnet

          # :lang org +roam2
          sqlite
        ] else
          [ ]);
    })

    (lib.mkIf cfg.neovim.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        withNodeJs = true;
        withRuby = true;
      };

      environment.systemPackages = with pkgs; [ editorconfig-core-c ];
    })

    (lib.mkIf cfg.vscode.enable {
      environment.systemPackages = with pkgs; [ vscode editorconfig-core-c ];
    })
  ];
}
