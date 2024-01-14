# I only use Emacs for org-roam (seriously... I only learned Emacs for
# that). Take note this profile doesn't setup Emacs-as-a-development-tool
# thing, rather Emacs-as-a-note-taking tool thing with the complete
# package.
{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.doom-emacs;
in
{
  options.users.foo-dogsquared.programs.doom-emacs.enable =
    lib.mkEnableOption "foo-dogsquared's Doom Emacs configuration";

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
      extraPackages = epkgs: with epkgs; [
        all-the-icons-nerd-fonts
        org-noter-pdftools
        org-pdftools
        org-roam
        org-roam-bibtex
        org-roam-ui
        pdf-tools
        vterm
      ];
    };

    # Automatically install Doom Emacs from here.
    home.mutableFile."${config.xdg.configHome}/emacs" = {
      url = "https://github.com/doomemacs/doomemacs.git";
      type = "git";
      extraArgs = [ "--depth" "1" ];
      postScript = ''
        ${config.xdg.configHome}/emacs/bin/doom install --no-config --no-fonts --install --force
        ${config.xdg.configHome}/emacs/bin/doom sync
      '';
    };

    home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];

    # Doom Emacs dependencies.
    home.packages = with pkgs; [
      # This is installed just to get Geiser to properly work.
      guile_3_0

      # Module dependencies.
      ## :checkers spell
      aspell
      aspellDicts.en
      aspellDicts.en-computers

      ## :tools lookup
      wordnet

      ## :lang org +roam2
      texlive.combined.scheme-medium
      (python3.withPackages (ps: with ps; [ jupyter ]))
      sqlite
      anystyle-cli
    ];

    # Enable Emacs server for them quicknotes.
    services.emacs = {
      enable = true;
      socketActivation.enable = true;
    };

    xdg.mimeApps.defaultApplications = {
      "application/json" = [ "emacs.desktop" ];
      "text/org" = [ "emacs.desktop" ];
      "text/plain" = [ "emacs.desktop" ];
    };
  };
}
