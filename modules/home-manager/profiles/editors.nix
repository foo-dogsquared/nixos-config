# My editor configurations. Take note I try to avert as much settings to create
# the configuration files with Nix. I prefer to handle the text editor
# configurations by hand as they are very chaotic and it is a hassle going
# through Nix whenever I need to change it.
#
# As much as I want 100% reproducibility with Nix, 5% of the remaining stuff
# for me is not worth to maintain.
{ config, lib, pkgs, ... }:

let cfg = config.profiles.editors;
in {
  options.profiles.editors = {
    neovim.enable = lib.mkEnableOption "foo-dogsquared's Neovim setup with Nix";
    emacs.enable = lib.mkEnableOption "foo-dogsquared's (Doom) Emacs setup";
    vscode.enable = lib.mkEnableOption "foo-dogsquared's Visual Studio Code setup";
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

      xdg.mimeApps.defaultApplications = {
        "application/json" = [ "nvim.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
      };
    })

    # I only use Emacs for org-roam (seriously... I only learned Emacs for
    # that). Take note this profile doesn't setup Emacs-as-a-development-tool
    # thing, rather Emacs-as-a-note-taking tool thing with the complete
    # package.
    (lib.mkIf cfg.emacs.enable {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-unstable;
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
        texlive.combined.scheme-medium
        (python3.withPackages (ps: with ps; [ jupyter ]))
        sqlite
        anystyle-cli
      ];

      xdg.mimeApps.defaultApplications = {
        "application/json" = [ "emacs.desktop" ];
        "text/org" = [ "emacs.desktop" ];
        "text/plain" = [ "emacs.desktop" ];
      };
    })

    # The Visual Studio Code setup. Probably the hardest one to fully configure
    # not because it has extensions available which will make things harder.
    # This might make me not consider an extension and settings sync extension
    # for this.
    (lib.mkIf cfg.vscode.enable {
      programs.vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          # All the niceties for developmenties.
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          ms-vsliveshare.vsliveshare
          tailscale.vscode-tailscale

          # Additional language support.
          bbenoist.nix
          graphql.vscode-graphql
          ms-vscode.cmake-tools
          ms-vscode.cpptools
          ms-vscode.powershell

          # Extra editor niceties.
          eamodio.gitlens
          mkhl.direnv
          usernamehw.errorlens
          vadimcn.vscode-lldb

          # The other niceties.
          editorconfig.editorconfig
          vscode-icons-team.vscode-icons
        ];

        # Yay! Thank you!
        mutableExtensionsDir = true;

        userSettings = {
          # Editor configurations.
          "editor.fontFamily" = "monospace";
          "editor.fontSize" = 16;
          "editor.cursorStyle" = "block";
          "editor.minimap.renderCharacters" = false;
          "workbench.iconTheme" = "vscode-icons";
          "window.autoDetectColorScheme" = true;
          "accessibility.dimUnfocused.enable" = true;
          "accessibility.dimUnfocused.opacity" = 0.35;

          # Putting some conveniences.
          "files.autoSave" = "off";
          "update.showReleaseNotes" = false;
          "extensions.autoUpdate" = "onlyEnabledExtensions";
          "github.copilot.enable"."*" = false;

          # Extensions settings.
          "direnv.restart.automatic" = true;
          "gitlens.showWhatsNewAfterUpgrade" = false;
          "gitlens.showWelcomeOnInstall" = false;
          "gitlens.plusFeatures.enabled" = false;
        };
      };

      xdg.mimeApps.defaultApplications = {
        "application/json" = [ "code.desktop" ];
        "text/plain" = [ "code.desktop" ];
      };
    })
  ];
}
