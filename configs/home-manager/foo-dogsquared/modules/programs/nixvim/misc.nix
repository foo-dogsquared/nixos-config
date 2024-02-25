{ config, lib, pkgs, ... }:
{
  extraPlugins = builtins.map (path:
    pkgs.runCommand "vim-plugin-bare" { } ''
      mkdir -p "$out"
      cp -r ${path}/* "$out"
    '')
    (with pkgs; [
      "${decker}/share/vim-plugins/decker"
      "${fzf}/share/vim-plugins/fzf"
    ]);

  # Light your browser on fire, bebe.
  plugins.firenvim.enable = true;

  plugins.legendary-nvim = {
    enable = true;
    integrations.smart-splits.enable = true;
  };

  # Make it work.
  plugins.smart-splits.enable = true;

  # Project-specific Neovim configurations. Fancy.
  globals.exrc = true;
}
