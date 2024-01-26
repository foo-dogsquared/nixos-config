{ config, lib, pkgs, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.treesitter;
in
{
  options.nixvimConfigs.fiesta.setups.treesitter.enable =
    lib.mkEnableOption "tree-sitter setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable {
    # The main star of the show.
    plugins.treesitter = {
      enable = true;

      # Install all of the grammars with Nix. We can easily replace it if we
      # want to.
      nixGrammars = true;
      ensureInstalled = "all";

      # Enable all of its useful features.
      folding = true;
      indent = true;
    };

    # Enable some more context for me.
    plugins.treesitter-context = {
      enable = true;
      lineNumbers = true;
      maxLines = 10;
    };

    # Show me your moves.
    plugins.treesitter-textobjects = {
      enable = true;
    };
  };
}
