# Ah yes, the bane of my endless configuration hell (or heaven, whichever your personal preferences).
# Or specifically, Org-mode...
# Doom Emacs saved me from being a configuration demon.
{ config, options, lib, pkgs, ... }:

with lib;
let
  emacsOrgProtocolDesktopEntry = pkgs.makeDesktopItem {
    name = "org-protocol";
    desktopName = "Org-Protocol";
    exec = "emacsclient %u";
    icon = "emacs-icon";
    type = "Application";
    mimeType = "x-scheme-handler/org-protocol";
  };
in {
  options.modules.editors.emacs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    # Just make sure the unstable version of Emacs is available as a package by creating an overlay.
    pkg = mkOption {
      type = types.package;
      default = pkgs.emacs;
    };
  };

  config = mkIf config.modules.editors.emacs.enable {
    my.packages = with pkgs; [
      ((emacsPackagesNgGen config.modules.editors.emacs.pkg).emacsWithPackages
        (epkgs: [ epkgs.vterm ]))

      emacsOrgProtocolDesktopEntry

      # Doom dependencies
      git
      (ripgrep.override { withPCRE2 = true; })
      gnutls

      # Optional depedencies
      fd # faster projectile
      imagemagick # image-dired
      (lib.mkIf (config.programs.gnupg.agent.enable)
        pinentry_emacs) # gnupg-emacs
      zstd # for undo-fu-sessions

      # Module dependencies
      ## :checkers spell
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      #aspellDicts.en-science

      ## :checkers grammar
      languagetool

      ## :tools editorconfig
      editorconfig-core-c

      ## :tools lookup
      wordnet

      ## :tools lookup & :lang org+roam
      sqlite
    ];

    fonts.fonts = with pkgs; [ emacs-all-the-icons-fonts ];
  };
}
