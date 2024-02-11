{ config, lib, ... }:

let
  initLushBase16 = acc: index: color:
    acc + ''
      local ${index} = hsluv('#${color}')
    '';
in
{
  colorscheme = "bark-on-a-tree";

  colorschemes.lush = {
    enable = true;
    extraConfigLua = ''
      local lush = require('lush')
      local hsl = lush.hsl
      local hsluv = lush.hsluv
    '';
    themes =
      lib.mapAttrs (name: metadata: {
        extraConfigLua = ''
          ${lib.foldlAttrs initLushBase16 "" metadata.palette}

          vim.g.terminal_color_0 = base00.hex
          vim.g.terminal_color_1 = base08.hex
          vim.g.terminal_color_2 = base0B.hex
          vim.g.terminal_color_3 = base0A.hex
          vim.g.terminal_color_4 = base0D.hex
          vim.g.terminal_color_5 = base0E.hex
          vim.g.terminal_color_6 = base0C.hex
          vim.g.terminal_color_7 = base05.hex
          vim.g.terminal_color_8 = base03.hex
          vim.g.terminal_color_9 = base08.hex
          vim.g.terminal_color_10 = base0B.hex
          vim.g.terminal_color_11 = base0A.hex
          vim.g.terminal_color_12 = base0D.hex
          vim.g.terminal_color_13 = base0E.hex
          vim.g.terminal_color_14 = base0C.hex
          vim.g.terminal_color_15 = base07.hex
          vim.g.terminal_color_background = base00.hex
          vim.g.terminal_color_foreground = base0E.hex
        '';

        highlights = lib.mkMerge [
          rec {
            Normal = { fg.__raw = "base05"; bg.__raw = "base00"; };
            NormalFloat = {
              fg.__raw = "Normal.fg.saturate(15).lighten(5)";
              bg.__raw = "Normal.bg.saturate(15).lighten(5)";
            };
            Bold.gui = "bold";
            Debug.fg.__raw = "base08";
            Directory.fg.__raw = "base0D";
            Error = { fg.__raw = "base01"; bg.__raw = "base08"; };
            ErrorMsg.fg.__raw = "base08";
            Exception.fg.__raw = "base08";
            FoldColumn.fg.__raw = "base03";
            Folded = {
              fg.__raw = "base03";
              bg.__raw = "base01";
            };
            Italic.gui = "italic";
            Macro.fg.__raw = "base08";
            ModeMsg.fg.__raw = "base0B";
            MoreMsg.fg.__raw = "base0B";
            Question.fg.__raw = "base0D";
            Search = {
              fg.__raw = "base00";
              bg.__raw = "base04";
            };
            IncSearch = {
              fg.__raw = "base00";
              bg.__raw = "base09";
            };
            Substitute = {
              fg.__raw = "base01";
              bg.__raw = "base0A";
            };

            TooLong.fg.__raw = "base08";
            Underlined = { fg.__raw = "base08"; };
            WarningMsg = { fg.__raw = "base08"; };
            WildMenu = { fg.__raw = "base08"; bg.__raw = "base0A"; };
            Title.fg.__raw = "base0D";
            Conceal.fg.__raw = "base0D";
            Cursor = { fg.__raw = "base00"; bg.__raw = "base05"; };
            NonText = { fg.__raw = "base03"; };
            LineNr = { fg.__raw = "base02.lighten(25)"; bg.__raw = "base00"; };
            LineNrNC = { fg.__raw = "base02.lighten(25)"; bg.__raw = "base01"; };
            SignColumn = { fg.__raw = "base01.lighten(40)"; };
            StatusLine = { fg.__raw = "base02"; bg.__raw = "base01.darken(60)"; };
            StatusLineNC = { fg.__raw = "base02"; bg.__raw = "base01.darken(30)"; };
            VertSplit = { fg.__raw = "base02"; bg.__raw = "base00"; };
            ColorColumn = { fg.__raw = "base01.lighten(25)"; bg.__raw = "base01.darken(25)"; };
            CursorLine = { bg.__raw = "base01.saturate(-5).darken(15)"; };
            CursorColumn = CursorLine;
            CursorLineNr.fg.__raw = "base0A";
            Visual = lib.mkMerge [
              CursorColumn
              { fg.__raw = lib.mkForce "base03.lighten(15)"; }
            ];
            VisualNOS = { fg.__raw = "base08"; };
            QuickFixLine = { bg.__raw = "base00"; };
            QFFileName = { fg.__raw = "base0A"; };
            QFLineNr = { fg.__raw = "base04"; };
            PMenu = { fg.__raw = "base05"; bg.__raw = "base01"; };
            PMenuSel = { fg.__raw = "base01"; bg.__raw = "base05"; };
            TabLineSel = { fg.__raw = "base00"; bg.__raw = "base0A"; };
            TabLine = { fg.__raw = "base03"; bg.__raw = "base00.darken(15)"; };
            TabLineFill = { fg.__raw = "base03"; bg.__raw = "base00.darken(25)"; };
            EndOfBuffer = { fg.__raw = "base01.lighten(20)"; bg.__raw = "base01.darken(20)"; };

            # Standard syntax highlighting
            Boolean = { fg.__raw = "base09"; };
            Character = { fg.__raw = "base08"; };
            Comment = { fg.__raw = "base03"; gui = "italic"; };
            Conditional = { fg.__raw = "base0E"; };
            Constant = { fg.__raw = "base09"; };
            Define = { fg.__raw = "base0E"; };
            Delimiter = { fg.__raw = "base0F.lighten(10)"; };
            Float = { fg.__raw = "base09"; };
            Function = { fg.__raw = "base0D"; };
            Identifier = { fg.__raw = "base0A"; };
            Include = { fg.__raw = "base0D"; };
            Keyword = { fg.__raw = "base0E"; };
            Label = { fg.__raw = "base0A"; };
            Number = { fg.__raw = "base03"; };
            Operator = { fg.__raw = "base03"; };
            PreProc = { fg.__raw = "base0A"; };
            Repeat = { fg.__raw = "base0A"; };
            Special = { fg.__raw = "base0C"; };
            SpecialChar = { fg.__raw = "base0F.lighten(15).saturate(10)"; };
            Statement = { fg.__raw = "base08"; };
            StorageClass = { fg.__raw = "base0A"; };
            String = { fg.__raw = "base0B"; };
            Structure = { fg.__raw = "base0E"; };
            Tag = { fg.__raw = "base0A"; };
            Todo = { fg.__raw = "base0A"; bg.__raw = "base01"; };
            Type = { fg.__raw = "base0A"; };
            Typedef = { fg.__raw = "base0A"; };

            # Help
            HelpDoc = { fg.__raw = "base05"; bg.__raw = "base0D"; gui = "bold;italic"; };
            HelpIgnore = { fg.__raw = "base0B"; gui = "bold;italic"; };

            # C highlighting
            cOperator = { fg.__raw = "base0C"; };
            cPreCondit = { fg.__raw = "base0E"; };

            # C# highlighting
            csClass = { fg.__raw = "base0A"; };
            csAttribute = { fg.__raw = "base0A"; };
            csModifier = { fg.__raw = "base0E"; };
            csType = { fg.__raw = "base08"; };
            csUnspecifiedStatement = { fg.__raw = "base0D"; };
            csContextualStatement = { fg.__raw = "base0E"; };
            csNewDecleration = { fg.__raw = "base08"; };

            # CSS highlighting
            cssBraces = { fg.__raw = "base05"; };
            cssClassName = { fg.__raw = "base0E"; };
            cssColor = { fg.__raw = "base0C"; };

            # Diff highlighting
            DiffAdd = { fg.__raw = "base0B"; bg.__raw = "base0B.darken(80)"; };
            DiffAdded = { fg.__raw = "base0B"; bg.__raw = "base0B.darken(80)"; };
            DiffNewFile = { fg.__raw = "base0B"; bg.__raw = "base0B.darken(80)"; };

            DiffDelete = { fg.__raw = "base08"; bg.__raw = "base08.darken(80)"; };
            DiffRemoved = { fg.__raw = "base08"; bg.__raw = "base08.darken(80)"; };

            DiffChange = { fg.__raw = "base03"; bg.__raw = "base03.darken(60)"; };
            DiffFile = { fg.__raw = "base03"; bg.__raw = "base03.darken(60)"; };
            DiffLine = { fg.__raw = "base03"; bg.__raw = "base03.darken(60)"; };
            DiffText = { fg.__raw = "base03"; bg.__raw = "base03.darken(60)"; };

            # Git highlighting
            gitcommitOverflow = { fg.__raw = "base08"; };
            gitcommitSummary = { fg.__raw = "base0B"; };
            gitcommitComment = { fg.__raw = "base03"; };
            gitcommitUntracked = { fg.__raw = "base03"; };
            gitcommitDiscarded = { fg.__raw = "base03"; };
            gitcommitSelected = { fg.__raw = "base03"; };
            gitcommitHeader = { fg.__raw = "base0E"; };
            gitcommitSelectedType = { fg.__raw = "base0D"; };
            gitcommitUnmergedType = { fg.__raw = "base0D"; };
            gitcommitDiscardedType = { fg.__raw = "base0D"; };
            gitcommitBranch = { fg.__raw = "base09"; gui = "bold"; };
            gitcommitUntrackedFile = { fg.__raw = "base0A"; };
            gitcommitUnmergedFile = { fg.__raw = "base08"; gui = "bold"; };
            gitcommitDiscardedFile = { fg.__raw = "base08"; gui = "bold"; };
            gitcommitSelectedFile = { fg.__raw = "base0B"; gui = "bold"; };

            # HTML highlighting
            htmlBold = { fg.__raw = "base0A"; };
            htmlItalic = { fg.__raw = "base0E"; };
            htmlEndTag = { fg.__raw = "base05"; };
            htmlTag = { fg.__raw = "base05"; };

            # JavaScript highlighting
            javaScript = { fg.__raw = "base05"; };
            javaScriptBraces = { fg.__raw = "base05"; };
            javaScriptNumber = { fg.__raw = "base09"; };

            # pangloss/vim-javascript highlighting
            jsOperator = { fg.__raw = "base0D"; };
            jsStatement = { fg.__raw = "base0E"; };
            jsReturn = { fg.__raw = "base0E"; };
            jsThis = { fg.__raw = "base08"; };
            jsClassDefinition = { fg.__raw = "base0A"; };
            jsFunction = { fg.__raw = "base0E"; };
            jsFuncName = { fg.__raw = "base0D"; };
            jsFuncCall = { fg.__raw = "base0D"; };
            jsClassFuncName = { fg.__raw = "base0D"; };
            jsClassMethodType = { fg.__raw = "base0E"; };
            jsRegexpString = { fg.__raw = "base0C"; };
            jsGlobalObjects = { fg.__raw = "base0A"; };
            jsGlobalNodeObjects = { fg.__raw = "base0A"; };
            jsExceptions = { fg.__raw = "base0A"; };
            jsBuiltins = { fg.__raw = "base0A"; };

            # Mail highlighting
            mailQuoted1 = { fg.__raw = "base0A"; };
            mailQuoted2 = { fg.__raw = "base0B"; };
            mailQuoted3 = { fg.__raw = "base0E"; };
            mailQuoted4 = { fg.__raw = "base0C"; };
            mailQuoted5 = { fg.__raw = "base0D"; };
            mailQuoted6 = { fg.__raw = "base0A"; };
            mailURL = { fg.__raw = "base0D"; };
            mailEmail = { fg.__raw = "base0D"; };

            # Markdown highlighting
            markdownh1 = { fg.__raw = "base0D"; gui = "bold"; };
            markdownh2 = { fg.__raw = "base0D"; gui = "bold"; };
            markdownh3 = { fg.__raw = "base0D"; gui = "bold"; };
            markdownh4 = { fg.__raw = "base0D"; gui = "bold"; };
            markdownh5 = { fg.__raw = "base0D"; gui = "bold"; };
            markdownh6 = { fg.__raw = "base0A"; gui = "bold"; };
            markdownRule = { fg.__raw = "markdownh2.bg"; gui = "bold"; };
            markdownItalic = { fg.__raw = "base05"; gui = "italic"; };
            markdownBold = { fg.__raw = "base05"; gui = "bold"; };
            markdownBoldItalic = { fg.__raw = "base05"; gui = "bold;italic"; };
            markdownCodeDelimiter = { fg.__raw = "base0B"; gui = "bold"; };
            markdownCode = { fg.__raw = "base07"; bg.__raw = "base00"; };
            markdownCodeBlock = { fg.__raw = "base0B"; };
            markdownFootnoteDefinition = { fg.__raw = "base05"; gui = "italic"; };
            markdownListMarker = { fg.__raw = "base05"; gui = "bold"; };
            markdownLineBreak = { fg.__raw = "base08"; gui = "underline"; };
            markdownError = { fg.__raw = "base05"; bg.__raw = "base00"; };
            markdownHeadingDelimiter = { fg.__raw = "base0D"; };
            markdownUrl = { fg.__raw = "base09"; };
            markdownFootnote = { fg.__raw = "base0E"; gui = "italic"; };
            markdownBlockquote = { fg.__raw = "base0C"; gui = "bold"; };
            markdownLinkText = { fg.__raw = "base08"; gui = "italic"; };

            # PHP highlighting
            phpMemberSelector = { fg.__raw = "base05"; };
            phpComparison = { fg.__raw = "base05"; };
            phpParent = { fg.__raw = "base05"; };
            phpMethodsVar = { fg.__raw = "base0C"; };

            # Python highlighting
            pythonOperator = { fg.__raw = "base0E"; };
            pythonRepeat = { fg.__raw = "base0E"; };
            pythonInclude = { fg.__raw = "base0E"; };
            pythonStatement = { fg.__raw = "base0E"; };

            # Ruby highlighting
            rubyAttribute = { fg.__raw = "base0D"; };
            rubyConstant = { fg.__raw = "base0A"; };
            rubyInterpolationDelimiter = { fg.__raw = "base0F"; };
            rubyRegexp = { fg.__raw = "base0C"; };
            rubySymbol = { fg.__raw = "base0B"; };
            rubyStringDelimiter = { fg.__raw = "base0B"; };

            # SASS highlighting
            sassidChar = { fg.__raw = "base08"; };
            sassClassChar = { fg.__raw = "base09"; };
            sassInclude = { fg.__raw = "base0E"; };
            sassMixing = { fg.__raw = "base0E"; };
            sassMixinName = { fg.__raw = "base0D"; };

            # Spelling highlighting
            SpellBad = { gui = "undercurl"; };
            # Spelling highlighting
            SpellCap = { gui = "undercurl"; };
            SpellRare = { gui = "undercurl"; };

            # Java highlighting
            javaOperator = { fg.__raw = "base0D"; };

            # LSP highlighting
            LspDiagnosticsDefaultError = { fg.__raw = "base08"; };
            LspDiagnosticsDefaultWarning = { fg.__raw = "base09"; };
            LspDiagnosticsDefaultHint = { fg.__raw = "base0A"; };
            LspDiagnosticsDefaultInformation = { fg.__raw = "base0B"; };

            # XML highlighting
            xmlTagName = { fg.__raw = "base0D"; };
            xmlCdatastart = { fg.__raw = "base0A"; };
            xmlEndTag = { fg.__raw = "xmlTagName.bg"; };
            xmlCdataCdata = { fg.__raw = "xmlCdatastart.bg"; };

            # MatchParen
            MatchParen = { fg.__raw = "base07"; bg.__raw = "base08"; };

            # CodeQL
            CodeqlAstFocus = { fg.__raw = "base00"; bg.__raw = "base03"; };

            # Diff highlighting
            GitSignsAdd = { fg.__raw = "base0B"; };
            GitSignsDelete = { fg.__raw = "base08"; };
            GitSignsChange = { fg.__raw = "base03"; };

            # Indent-Blank-Lines
            IndentGuide = { fg.__raw = "base01"; bg.__raw = "base05"; };
          }

          (lib.mkIf config.plugins.telescope.enable {
            TelescopeNormal = { fg.__raw = "base05"; bg.__raw = "base01"; };
            TelescopeBorder = { fg.__raw = "base00"; bg.__raw = "base01"; };
            TelescopePromptPrefix = { fg.__raw = "base0A"; bg.__raw = "base01"; };
            TelescopeMatching = { fg.__raw = "base0D"; bg.__raw = "base01"; };
            TelescopeSelection = { fg.__raw = "base0A"; bg.__raw = "base01"; };
            TelescopeSelectionCaret = { fg.__raw = "base0A"; bg.__raw = "base01"; };
          })

          (lib.mkIf config.plugins.treesitter.enable {
            TSError = { fg.__raw = "Error.bg"; gui = "bold"; };
            TSPunctDelimiter = { fg.__raw = "base05"; };
            TSPunctBracket = { fg.__raw = "base05"; };
            TSConstant = { fg.__raw = "Constant.fg"; };
            TSConstBuiltin = { fg.__raw = "Constant.fg"; };
            TSConstMacro = { fg.__raw = "Constant.fg"; };
            TSString = { fg.__raw = "String.fg"; };
            TSStringRegex = { fg.__raw = "base03"; };
            TSStringEscape = { fg.__raw = "base03"; };
            TSCharacter = { fg.__raw = "Character.fg"; };
            TSNumber = { fg.__raw = "Number.fg"; };
            TSBoolean = { fg.__raw = "Boolean.fg"; };
            TSFloat = { fg.__raw = "Number.fg"; };
            TSFunction = { fg.__raw = "Function.fg"; };
            TSFuncBuiltin = { fg.__raw = "Function.fg"; };
            TSFuncMacro = { fg.__raw = "Function.fg"; };
            TSParameter = { fg.__raw = "base0D"; };
            TSConstructor = { fg.__raw = "base0E"; };
            TSKeywordFunction = { fg.__raw = "base0E"; };
            TSLiteral = { fg.__raw = "base04"; gui = "bold"; };
            TSVariable = { fg.__raw = "base03.lighten(25)"; };
            TSVariableBuiltin = { fg.__raw = "base0E"; };
            TSParameterReference = { fg.__raw = "TSParameter.fg"; };
            TSMethod = { fg.__raw = "Function.fg"; };
            TSConditional = { fg.__raw = "Conditional.fg"; };
            TSRepeat = { fg.__raw = "Repeat.fg"; };
            TSLabel = { fg.__raw = "Label.fg"; };
            TSOperator = { fg.__raw = "Operator.fg"; };
            TSKeyword = { fg.__raw = "Keyword.fg"; };
            TSException = { fg.__raw = "Exception.fg"; };
            TSType = { fg.__raw = "Type.fg"; };
            TSTypeBuiltin = { fg.__raw = "Type.fg"; };
            TSStructure = { fg.__raw = "Structure.fg"; };
            TSInclude = { fg.__raw = "Include.fg"; };
            TSAnnotation = { fg.__raw = "base03"; };
            TSStrong = { fg.__raw = "base05"; bg.__raw = "base00"; gui = "bold"; };
            TSTitle = { fg.__raw = "base0D"; };
          })
        ];
      }) config.tinted-theming.schemes;
  };
}
