{ config, lib, pkgs, helpers, hmConfig, ... }:

{
  # The main star of the show.
  plugins.neorg.enable = true;

  # Set it up, set it up, set it up.
  plugins.neorg.settings = {
    lazy_loading = true;

    load = lib.mkMerge [
      {
        # Pretty much required with tree-sitter integration and all.
        "core.defaults" = helpers.emptyTable;

        # Conceal your blade (which is the markup, in which it is pretty sharp to
        # look at).
        "core.concealer" = helpers.emptyTable;

        # Dear diary...
        "core.journal".config = { strategy = "flat"; };

        # Norg ripping a page from org-mode.
        "core.ui.calendar" = helpers.emptyTable;

        # Manage your note workspaces.
        "core.dirman".config = {
          workspaces = {
            personal = "${hmConfig.home.homeDirectory}/library/notes";
            work = "${hmConfig.xdg.userDirs.documents}/Notes";
            wiki = "${hmConfig.xdg.userDirs.documents}/Wiki";
          };
        };
      }

      (lib.mkIf config.plugins.cmp.enable {
        "core.completion".config.engine = "nvim-cmp";
      })
    ];
  };

  # Install the common text markup tree-sitter grammars.
  plugins.treesitter.grammarPackages =
    with config.plugins.treesitter.package.builtGrammars;
    [
      bibtex
      cooklang
      latex
      ledger
      markdown
      markdown_inline
      org
      po
      pod
      rst
      tsx
    ]
    # Install the tree-sitter parsers required for the core.defaults Neorg
    # module.
    ++ lib.optionals (config.plugins.neorg.settings ? load."core.defaults")
    (with pkgs.tree-sitter-grammars; [
      tree-sitter-norg
      tree-sitter-norg-meta
    ]);
}
