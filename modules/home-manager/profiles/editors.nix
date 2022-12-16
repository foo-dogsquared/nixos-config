# My editor configurations. Take note I try to avert as much settings to create
# the configuration files with Nix. I prefer to handle the text editor
# configurations by hand as they are very chaotic and it is a hassle going
# through Nix whenever I need to change it.
#
# As much as I want 100% reproducibility with Nix, 5% of the remaining stuff
# for me is not worth to maintain.
{ config, options, lib, pkgs, ... }:

let cfg = config.profiles.editors;
in {
  options.profiles.editors = {
    neovim.enable = lib.mkEnableOption "foo-dogsquared's Neovim setup with Nix";
    emacs.enable = lib.mkEnableOption "foo-dogsquared's (Doom) Emacs setup";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.neovim.enable {
      programs.neovim = {
        enable = true;
        package = pkgs.neovim-nightly;
        withPython3 = true;
        withRuby = true;
        withNodeJs = true;

        plugins = with pkgs.vimPlugins; [
          parinfer-rust
        ];
      };
    })

    # I only use Emacs for org-roam (seriously... I only learned Emacs for
    # that). Take note this profile doesn't setup Emacs-as-a-development-tool
    # thing, rather Emacs-as-a-note-taking tool thing with the complete
    # package.
    (lib.mkIf cfg.emacs.enable {
      programs.emacs = {
        enable = true;
        package = pkgs.emacsUnstable;
        extraPackages = epkgs: with epkgs; [
          vterm
          pdf-tools
          org-pdftools
          org-roam
          org-roam-ui
          org-roam-bibtex
          org-noter-pdftools
        ];
      };

      # Doom Emacs dependencies.
      home.packages = with pkgs; [
        # This is installed just to get Geiser to properly work.
        guile_3_0

        # Required dependencies.
        ripgrep
        gnutls
        emacs-all-the-icons-fonts

        # Optional dependencies.
        fd
        imagemagick
        zstd

        # Module dependencies.
        ## :checkers spell
        aspell
        aspellDicts.en
        aspellDicts.en-computers

        ## :tools lookup
        wordnet

        ## :lang org +roam2
        sqlite
        anystyle-cli
      ];
    })
  ];
}
