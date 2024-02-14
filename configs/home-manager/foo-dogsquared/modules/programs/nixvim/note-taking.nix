{ config, lib, pkgs, ... }:

{
  # The main star of the show.
  plugins.neorg.enable = true;

  # Set it up, set it up, set it up.
  plugins.neorg.extraOptions = {
    lazy_loading = true;

    load = {
      # Pretty much required with tree-sitter integration and all.
      "core.defaults" = { __empty = null; };

      # Conceal your blade (which is the markup, in which it is pretty sharp to
      # look at).
      "core.concealer" = { __empty = null; };

      # Dear diary...
      "core.journal" = {
        strategy = "flat";
        toc_format = [ "yy" "mm" "dd" "link" "title" ];
      };

      # Norg ripping a page from org-mode.
      "core.ui.calendar" = { __empty = null; };

      # Manage your note workspaces.
      "core.dirman" = {
        config.workspaces = {
          personal = "~/library/notes";
        };
      };
    };
  };

  # Install the common text markup tree-sitter grammars.
  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
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
    typst
  ]
  # Install the tree-sitter parsers required for the core.defaults Neorg
  # module.
  ++ lib.optionals (config.plugins.neorg.extraOptions ? load."core.defaults")
    (with pkgs.tree-sitter-grammars; [
      tree-sitter-norg
      tree-sitter-norg-meta
    ]);
}
