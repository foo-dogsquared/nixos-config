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
      mode = "topline";
      separator = "*";
    };

    # Show me your moves.
    plugins.treesitter-textobjects = {
      enable = true;
      lspInterop = {
        enable = true;
        border = "none";
        peekDefinitionCode =
          let
            bindingPrefix = "<leader>d";

            mkQueryMappings = query: binding:
              lib.nameValuePair "${bindingPrefix}${binding}" {
                desc = "Peek definition of ${query}";
                query = "@${query}.outer";
              };
          in
            lib.mapAttrs' mkQueryMappings {
              "function" = "f";
              "class" = "F";
            };
      };
      move = lib.mkMerge ([{
        enable = true;
        setJumps = true;
      }]
      ++ (
        let
          motions = lib.cartesianProductOfSets {
            region = [ "Start" "End" ];
            jumpDirection = [ "Previous" "Next" ];
            variant = [ "outer" "inner" ];
          };

          motionMap = {
            outerPrevious = "[";
            outerNext = "]";
            innerPrevious = "[[";
            innerNext = "]]";
          };

          actionDesc = variant: jumpDirection: query:
            if variant == "inner"
            then "Jump to inner part of the ${jumpDirection} ${query}"
            else "Jump to ${jumpDirection} ${query}";

          mkQueryMappings =
            # The accumulator. Should be a list where it contains all of the
            # modules to be merged.
            acc:

            # The query object of the treesitter node. All queries are
            # assumed to be "@$QUERY.outer".
            query:

            # A set of bindings to be used for each jump direction.
            bindings:
              let
                mappings = builtins.map (motion:
                  let
                    inherit (motion) region jumpDirection variant;
                    jumpDirection' = lib.strings.toLower jumpDirection;
                    binding' = bindings.${jumpDirection'};
                    bindingPrefix = motionMap."${variant}${jumpDirection}";
                  in
                  {
                    "goto${jumpDirection}${region}" = {
                      "${bindingPrefix}${binding'}" = {
                        desc = actionDesc variant jumpDirection' query;
                        query = "@${query}.${variant}";
                      };
                    };
                  }) motions;
              in
                acc ++ mappings;
        in
        lib.foldlAttrs mkQueryMappings [ ] {
          "function" = { previous = "M"; next  = "m"; };
          "block" = { previous = "B"; next = "b"; };
          "call" = { previous = "F"; next = "f"; };
          "class" = { previous = "C"; next = "c"; };
          "conditional" = { previous = "D"; next = "d"; };
          "statement" = { previous = "S"; next = "s"; };
          "loop" = { previous = "L"; next = "l"; };
        }));
      select = {
        enable = true;
        lookahead = true;
        selectionModes = {
          "@function.outer" = "V";
          "@class.outer" = "<c-v>";
          "@block.outer" = "<c-v>";
        };
        keymaps =
          let
            prefixMap = {
              "outer" = {
                key = "a";
                desc = query: "Select around the ${query} region";
              };
              "inner" = {
                key = "i";
                desc = query: "Select inner part of the ${query} region";
              };
            };

            # A function that creates a pair of keymaps: one for the outer and
            # inner part of the query. As such, it assumes the query has an
            # outer and inner variant.
            mkQueryMappings =
              # The textobject query, assumed as "@$QUERY.$VARIANT".
              query:

              # The keymap sequence to affix for the mapping pair.
              binding:

              let
                mappingsList =
                  builtins.map (variant:
                    let
                      prefixMap' = prefixMap.${variant};
                    in
                    lib.nameValuePair "${prefixMap'.key}${binding}" {
                      query = "@${query}.${variant}";
                      desc = prefixMap'.desc query;
                    }) [ "outer" "inner" ];
              in
                lib.listToAttrs mappingsList;
          in
          lib.concatMapAttrs mkQueryMappings {
            "function" = "m";
            "call" = "f";
            "class" = "c";
            "block" = "b";
            "loop" = "l";
            "statement" = "s";
            "attribute" = "a";
          };
      };
      swap = lib.mkMerge (
        [{ enable = true; }]
        ++ (
          let
            motions = lib.cartesianProductOfSets {
              jumpDirection = [ "Previous" "Next" ];
              variant = [ "outer" ];
            };

            motionMap = {
              "outerPrevious" = "<leader>S";
              "outerNext" = "<leader>s";
            };

            actionDesc = variant: jumpDirection: query:
              if variant == "inner"
              then "Jump to inner part of the ${jumpDirection} ${query}"
              else "Jump to ${jumpDirection} ${query}";

            mkQueryMappings = acc: query: bindings:
              let
                mappings = builtins.map (motion:
                  let
                    inherit (motion) jumpDirection variant;
                    jumpDirection' = lib.strings.toLower jumpDirection;
                    binding' = bindings.${jumpDirection'};
                    bindingPrefix = motionMap."${variant}${jumpDirection}";
                  in
                  {
                    "swap${jumpDirection}" = {
                      "${bindingPrefix}${binding'}" = {
                        desc = actionDesc variant jumpDirection' query;
                        query = "@${query}.${variant}";
                      };
                    };
                  }) motions;
              in
                acc ++ mappings;
          in
            lib.foldlAttrs mkQueryMappings [ ] {
              "function" = { next = "f"; previous = "F"; };
              "parameter" = { next = "a"; previous = "A"; };
              "conditional" = { next = "d"; previous = "D"; };
            }));
    };
  };
}
