{ config, lib, ... }:

let
  nixvimCfg = config.nixvimConfigs.trovebelt;
  cfg = nixvimCfg.setups.treesitter;
in
{
  options.nixvimConfigs.trovebelt.setups.treesitter.enable =
    lib.mkEnableOption "tree-sitter setup with all parsers installed";

  config = lib.mkIf cfg.enable {
    plugins.treesitter = {
      enable = true;

      # Install all of the grammars with Nix. We can easily replace it if we
      # want to.
      nixGrammars = true;
      nixvimInjections = true;
      grammarPackages = config.plugins.treesitter.package.allGrammars;

      # Enable all of its useful features.
      folding = true;
      indent = true;
      incrementalSelection.enable = true;
    };

    # Enable some more context for me.
    plugins.treesitter-context = {
      enable = true;
      lineNumbers = true;
      maxLines = 7;
      mode = "cursor";
      separator = "*";
    };

    # Some niceties for refactoring.
    plugins.treesitter-refactor = {
      enable = true;
      highlightCurrentScope.enable = true;
      highlightDefinitions.enable = true;
      navigation.enable = true;
      smartRename.enable = true;
    };
  };
}
