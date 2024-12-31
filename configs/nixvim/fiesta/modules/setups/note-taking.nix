{ config, lib, pkgs, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.note-taking;
in
{
  options.nixvimConfigs.fiesta.setups.note-taking.enable =
    lib.mkEnableOption "basic note-taking setup";

  config = lib.mkIf cfg.enable {
    # The main star of the show.
    plugins.neorg.enable = true;

    # Set it up, set it up.
    plugins.neorg.settings = {
      lazy_loading = true;

      # The basic bare essentials.
      load = {
        "core.defaults" = helpers.emptyTable;
        "core.concealer" = helpers.emptyTable;
      };
    };

    # Install the tree-sitter parsers.
    plugins.treesitter.grammarPackages =
      lib.mkIf
        (config.plugins.neorg.settings ? load."core.defaults")
        (with pkgs.tree-sitter-grammars; [
          tree-sitter-norg
          tree-sitter-norg-meta
        ]);
  };
}
