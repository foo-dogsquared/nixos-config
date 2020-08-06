# Visual Studio Code is the middle ground between a text editor and an IDE.
# Perfect for managing medium-sized software projects.
{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.editors.vscode;
in {
  options.modules.editors.vscode = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  # I'll be using the home-manager module for this one since it already did the work for me.
  # If I were to create one from scratch, it'll most likely end up similar anyways.
  config = mkIf cfg.enable { 
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        # Material Icon theme
        PKief.material-icon-theme

        # Material theme that comes with multiple variants
        Equinusocio.vsc-material-theme

        # The official implementation for the Nord color scheme
        arcticicestudio.nord-visual-studio-code

        # ESLint
        dbaeumer.vscode-eslint

        # Supercharged Git integration into the editor
        eamodio.gitlens

        # A code formatter
        esbenp.prettier-vscode
      ];
    };
  };
}
