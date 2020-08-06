# modules/editors/emacs.nix - https://gnu.org/emacs/
# Ah yes, the bane of my endless configuration hell (or heaven, whichever your personal preferences).
# Or specifically, Org-mode...
# Doom Emacs saved me from being a configuration demon.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.editors.emacs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.emacs.enable {
    home.packages = with pkgs; [
      # Doom dependencies
      git
      (ripgrep.override { withPCRE2 = true; })
      gnutls

      # Optional depedencies
      fd                # faster projectile
      imagemagick       # image-dired
      # (lib.mkIf (config.programs.gnupg.agent.enable)
      #  pinentry_emacs)    # gnupg-emacs
      zstd      # for undo-fu-sessions

      # Module dependencies
      ## :checkers spell
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science

      ## :checkers grammar
      languagetool

      ## :tools editorconfig
      editorconfig-core-c

      ## :tools lookup & :lang org+roam
      sqlite
    ] ++

    ## :lang javascript
    (if config.modules.dev.javascript.node.enable then [
      nodePackages.javascript-typescript-langserver     # The LSP for JS/TS.
    ] else []) ++

    ## :lang cc
    (if config.modules.dev.cc.enable then [
      ccls
    ] else []);


    # Placing the Doom Emacs config.
    xdg.configFile."doom" = {
      source = ../../config/emacs;
      recursive = true;
    };
  };
}
