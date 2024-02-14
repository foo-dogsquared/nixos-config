{ config, lib, helpers, ... }:

let
  inherit (helpers) mkRaw;

  initLushBase16 = acc: index: color:
    acc + ''
      local ${index} = hsluv('#${color}')
    '';

  sym = query: ''sym("${query}")'';
in
{
  colorscheme =
    if config.tinted-theming.schemes?"bark-on-a-tree"
    then (lib.mkForce "bark-on-a-tree")
    else (lib.mkDefault "default");

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
            Normal = { fg = mkRaw "base05"; bg = mkRaw "base00"; };
            NormalFloat = {
              fg = mkRaw "Normal.fg.saturate(15).lighten(5)";
              bg = mkRaw "Normal.bg.saturate(15).lighten(5)";
            };
            Bold.gui = "bold";
            Debug.fg = mkRaw "base08";
            Directory.fg = mkRaw "base0D";
            Error = { fg = mkRaw "base01"; bg = mkRaw "base08"; };
            ErrorMsg.fg = mkRaw "base08";
            Exception.fg = mkRaw "base08";
            FoldColumn.fg = mkRaw "base03";
            Folded = {
              fg = mkRaw "base03";
              bg = mkRaw "base01";
            };
            Italic.gui = "italic";
            Macro.fg = mkRaw "base08";
            ModeMsg.fg = mkRaw "base0B";
            MoreMsg.fg = mkRaw "base0B";
            Question.fg = mkRaw "base0D";
            Search = {
              fg = mkRaw "base00";
              bg = mkRaw "base04";
            };
            IncSearch = {
              fg = mkRaw "base00";
              bg = mkRaw "base09";
            };
            Substitute = {
              fg = mkRaw "base01";
              bg = mkRaw "base0A";
            };

            TooLong.fg = mkRaw "base08";
            Underlined = { fg = mkRaw "base08"; };
            WarningMsg = { fg = mkRaw "base08"; };
            WildMenu = { fg = mkRaw "base08"; bg = mkRaw "base0A"; };
            Title.fg = mkRaw "base0D";
            Conceal.fg = mkRaw "base0D";
            Cursor = { fg = mkRaw "base00"; bg = mkRaw "base05"; };
            NonText = { fg = mkRaw "base03"; };
            LineNr = { fg = mkRaw "base02.lighten(25)"; bg = mkRaw "base00"; };
            LineNrNC = { fg = mkRaw "base02.lighten(25)"; bg = mkRaw "base01"; };
            SignColumn = { fg = mkRaw "base01.lighten(40)"; };
            StatusLine = { fg = mkRaw "base02"; bg = mkRaw "base01.darken(60)"; };
            StatusLineNC = { fg = mkRaw "base02"; bg = mkRaw "base01.darken(30)"; };
            VertSplit = { fg = mkRaw "base02"; bg = mkRaw "base00"; };
            ColorColumn = { fg = mkRaw "base01.lighten(25)"; bg = mkRaw "base01.darken(25)"; };
            CursorLine = { bg = mkRaw "base01.saturate(-5).darken(15)"; };
            CursorColumn = CursorLine;
            CursorLineNr.fg = mkRaw "base0A";
            Visual = {
              fg = mkRaw "base03.lighten(15)";
              bg = mkRaw "CursorColumn.bg.darken(15)";
            };
            VisualNOS = { fg = mkRaw "base08"; };
            QuickFixLine = { bg = mkRaw "base00"; };
            QFFileName = { fg = mkRaw "base0A"; };
            QFLineNr = { fg = mkRaw "base04"; };
            PMenu = { fg = mkRaw "base05"; bg = mkRaw "base01"; };
            PMenuSel = { fg = mkRaw "base01"; bg = mkRaw "base05"; };
            TabLineSel = { fg = mkRaw "base00"; bg = mkRaw "base0A"; };
            TabLine = { fg = mkRaw "base03"; bg = mkRaw "base00.darken(15)"; };
            TabLineFill = { fg = mkRaw "base03"; bg = mkRaw "base00.darken(25)"; };
            EndOfBuffer = { fg = mkRaw "base01.lighten(20)"; bg = mkRaw "base01.darken(20)"; };

            # Standard syntax highlighting
            Boolean = { fg = mkRaw "base09"; };
            Character = { fg = mkRaw "base08"; };
            Comment = { fg = mkRaw "base03"; gui = "italic"; };
            Conditional = { fg = mkRaw "base0E"; };
            Constant = { fg = mkRaw "base09"; };
            Define = { fg = mkRaw "base0E"; };
            Delimiter = { fg = mkRaw "base0F.lighten(10)"; };
            Float = { fg = mkRaw "base09"; };
            Function = { fg = mkRaw "base0D"; };
            Identifier = { fg = mkRaw "base0A"; };
            Include = { fg = mkRaw "base0D"; };
            Keyword = { fg = mkRaw "base0E"; };
            Label = { fg = mkRaw "base0A"; };
            Number = { fg = mkRaw "base03"; };
            Operator = { fg = mkRaw "base03"; };
            PreProc = { fg = mkRaw "base0A"; };
            Repeat = { fg = mkRaw "base0A"; };
            Special = { fg = mkRaw "base0C"; };
            SpecialChar = { fg = mkRaw "base0F.lighten(15).saturate(10)"; };
            Statement = { fg = mkRaw "base08"; };
            StorageClass = { fg = mkRaw "base0A"; };
            String = { fg = mkRaw "base0B"; };
            Structure = { fg = mkRaw "base0E"; };
            Tag = { fg = mkRaw "base0A"; };
            Todo = { fg = mkRaw "base0A"; bg = mkRaw "base01"; };
            Type = { fg = mkRaw "base0A"; };
            Typedef = { fg = mkRaw "base0A"; };

            # Help
            HelpDoc = { fg = mkRaw "base05"; bg = mkRaw "base0D"; gui = "bold;italic"; };
            HelpIgnore = { fg = mkRaw "base0B"; gui = "bold;italic"; };

            # C highlighting
            cOperator = { fg = mkRaw "base0C"; };
            cPreCondit = { fg = mkRaw "base0E"; };

            # C# highlighting
            csClass = { fg = mkRaw "base0A"; };
            csAttribute = { fg = mkRaw "base0A"; };
            csModifier = { fg = mkRaw "base0E"; };
            csType = { fg = mkRaw "base08"; };
            csUnspecifiedStatement = { fg = mkRaw "base0D"; };
            csContextualStatement = { fg = mkRaw "base0E"; };
            csNewDecleration = { fg = mkRaw "base08"; };

            # CSS highlighting
            cssBraces = { fg = mkRaw "base05"; };
            cssClassName = { fg = mkRaw "base0E"; };
            cssColor = { fg = mkRaw "base0C"; };

            # Diff highlighting
            DiffAdd = { fg = mkRaw "base0B"; bg = mkRaw "base0B.darken(80)"; };
            DiffAdded = { fg = mkRaw "base0B"; bg = mkRaw "base0B.darken(80)"; };
            DiffNewFile = { fg = mkRaw "base0B"; bg = mkRaw "base0B.darken(80)"; };

            DiffDelete = { fg = mkRaw "base08"; bg = mkRaw "base08.darken(80)"; };
            DiffRemoved = { fg = mkRaw "base08"; bg = mkRaw "base08.darken(80)"; };

            DiffChange = { fg = mkRaw "base03"; bg = mkRaw "base03.darken(60)"; };
            DiffFile = { fg = mkRaw "base03"; bg = mkRaw "base03.darken(60)"; };
            DiffLine = { fg = mkRaw "base03"; bg = mkRaw "base03.darken(60)"; };
            DiffText = { fg = mkRaw "base03"; bg = mkRaw "base03.darken(60)"; };

            # Git highlighting
            gitcommitOverflow = { fg = mkRaw "base08"; };
            gitcommitSummary = { fg = mkRaw "base0B"; };
            gitcommitComment = { fg = mkRaw "base03"; };
            gitcommitUntracked = { fg = mkRaw "base03"; };
            gitcommitDiscarded = { fg = mkRaw "base03"; };
            gitcommitSelected = { fg = mkRaw "base03"; };
            gitcommitHeader = { fg = mkRaw "base0E"; };
            gitcommitSelectedType = { fg = mkRaw "base0D"; };
            gitcommitUnmergedType = { fg = mkRaw "base0D"; };
            gitcommitDiscardedType = { fg = mkRaw "base0D"; };
            gitcommitBranch = { fg = mkRaw "base09"; gui = "bold"; };
            gitcommitUntrackedFile = { fg = mkRaw "base0A"; };
            gitcommitUnmergedFile = { fg = mkRaw "base08"; gui = "bold"; };
            gitcommitDiscardedFile = { fg = mkRaw "base08"; gui = "bold"; };
            gitcommitSelectedFile = { fg = mkRaw "base0B"; gui = "bold"; };

            # HTML highlighting
            htmlBold = { fg = mkRaw "base0A"; };
            htmlItalic = { fg = mkRaw "base0E"; };
            htmlEndTag = { fg = mkRaw "base05"; };
            htmlTag = { fg = mkRaw "base05"; };

            # JavaScript highlighting
            javaScript = { fg = mkRaw "base05"; };
            javaScriptBraces = { fg = mkRaw "base05"; };
            javaScriptNumber = { fg = mkRaw "base09"; };

            # pangloss/vim-javascript highlighting
            jsOperator = { fg = mkRaw "base0D"; };
            jsStatement = { fg = mkRaw "base0E"; };
            jsReturn = { fg = mkRaw "base0E"; };
            jsThis = { fg = mkRaw "base08"; };
            jsClassDefinition = { fg = mkRaw "base0A"; };
            jsFunction = { fg = mkRaw "base0E"; };
            jsFuncName = { fg = mkRaw "base0D"; };
            jsFuncCall = { fg = mkRaw "base0D"; };
            jsClassFuncName = { fg = mkRaw "base0D"; };
            jsClassMethodType = { fg = mkRaw "base0E"; };
            jsRegexpString = { fg = mkRaw "base0C"; };
            jsGlobalObjects = { fg = mkRaw "base0A"; };
            jsGlobalNodeObjects = { fg = mkRaw "base0A"; };
            jsExceptions = { fg = mkRaw "base0A"; };
            jsBuiltins = { fg = mkRaw "base0A"; };

            # Mail highlighting
            mailQuoted1 = { fg = mkRaw "base0A"; };
            mailQuoted2 = { fg = mkRaw "base0B"; };
            mailQuoted3 = { fg = mkRaw "base0E"; };
            mailQuoted4 = { fg = mkRaw "base0C"; };
            mailQuoted5 = { fg = mkRaw "base0D"; };
            mailQuoted6 = { fg = mkRaw "base0A"; };
            mailURL = { fg = mkRaw "base0D"; };
            mailEmail = { fg = mkRaw "base0D"; };

            # Markdown highlighting
            markdownh1 = { fg = mkRaw "base0D"; gui = "bold"; };
            markdownh2 = { fg = mkRaw "base0D"; gui = "bold"; };
            markdownh3 = { fg = mkRaw "base0D"; gui = "bold"; };
            markdownh4 = { fg = mkRaw "base0D"; gui = "bold"; };
            markdownh5 = { fg = mkRaw "base0D"; gui = "bold"; };
            markdownh6 = { fg = mkRaw "base0A"; gui = "bold"; };
            markdownRule = { fg = mkRaw "markdownh2.bg"; gui = "bold"; };
            markdownItalic = { fg = mkRaw "base05"; gui = "italic"; };
            markdownBold = { fg = mkRaw "base05"; gui = "bold"; };
            markdownBoldItalic = { fg = mkRaw "base05"; gui = "bold;italic"; };
            markdownCodeDelimiter = { fg = mkRaw "base0B"; gui = "bold"; };
            markdownCode = { fg = mkRaw "base07"; bg = mkRaw "base00"; };
            markdownCodeBlock = { fg = mkRaw "base0B"; };
            markdownFootnoteDefinition = { fg = mkRaw "base05"; gui = "italic"; };
            markdownListMarker = { fg = mkRaw "base05"; gui = "bold"; };
            markdownLineBreak = { fg = mkRaw "base08"; gui = "underline"; };
            markdownError = { fg = mkRaw "base05"; bg = mkRaw "base00"; };
            markdownHeadingDelimiter = { fg = mkRaw "base0D"; };
            markdownUrl = { fg = mkRaw "base09"; };
            markdownFootnote = { fg = mkRaw "base0E"; gui = "italic"; };
            markdownBlockquote = { fg = mkRaw "base0C"; gui = "bold"; };
            markdownLinkText = { fg = mkRaw "base08"; gui = "italic"; };

            # PHP highlighting
            phpMemberSelector = { fg = mkRaw "base05"; };
            phpComparison = { fg = mkRaw "base05"; };
            phpParent = { fg = mkRaw "base05"; };
            phpMethodsVar = { fg = mkRaw "base0C"; };

            # Python highlighting
            pythonOperator = { fg = mkRaw "base0E"; };
            pythonRepeat = { fg = mkRaw "base0E"; };
            pythonInclude = { fg = mkRaw "base0E"; };
            pythonStatement = { fg = mkRaw "base0E"; };

            # Ruby highlighting
            rubyAttribute = { fg = mkRaw "base0D"; };
            rubyConstant = { fg = mkRaw "base0A"; };
            rubyInterpolationDelimiter = { fg = mkRaw "base0F"; };
            rubyRegexp = { fg = mkRaw "base0C"; };
            rubySymbol = { fg = mkRaw "base0B"; };
            rubyStringDelimiter = { fg = mkRaw "base0B"; };

            # SASS highlighting
            sassidChar = { fg = mkRaw "base08"; };
            sassClassChar = { fg = mkRaw "base09"; };
            sassInclude = { fg = mkRaw "base0E"; };
            sassMixing = { fg = mkRaw "base0E"; };
            sassMixinName = { fg = mkRaw "base0D"; };

            # Spelling highlighting
            SpellBad = { gui = "undercurl"; };
            SpellCap = { gui = "undercurl"; };
            SpellRare = { gui = "undercurl"; };

            # Java highlighting
            javaOperator = { fg = mkRaw "base0D"; };

            # XML highlighting
            xmlTagName = { fg = mkRaw "base0D"; };
            xmlCdatastart = { fg = mkRaw "base0A"; };
            xmlEndTag = { fg = mkRaw "xmlTagName.bg"; };
            xmlCdataCdata = { fg = mkRaw "xmlCdatastart.bg"; };

            # MatchParen
            MatchParen = { fg = mkRaw "base07"; bg = mkRaw "base08"; };

            # CodeQL
            CodeqlAstFocus = { fg = mkRaw "base00"; bg = mkRaw "base03"; };

            # Diff highlighting
            GitSignsAdd = { fg = mkRaw "base0B"; };
            GitSignsDelete = { fg = mkRaw "base08"; };
            GitSignsChange = { fg = mkRaw "base03"; };

            # Indent-Blank-Lines
            IndentGuide = { fg = mkRaw "base01"; bg = mkRaw "base05"; };
          }

          (lib.mkIf config.plugins.telescope.enable {
            TelescopeNormal = { fg = mkRaw "base05"; bg = mkRaw "base01"; };
            TelescopeBorder = { fg = mkRaw "base00"; bg = mkRaw "base01"; };
            TelescopePromptPrefix = { fg = mkRaw "base0A"; bg = mkRaw "base01"; };
            TelescopeMatching = { fg = mkRaw "base0D"; bg = mkRaw "base01"; };
            TelescopeSelection = { fg = mkRaw "base0A"; bg = mkRaw "base01"; };
            TelescopeSelectionCaret = { fg = mkRaw "base0A"; bg = mkRaw "base01"; };
          })

          # See `rb-delimiters-colors` help section for more details.
          (lib.mkIf config.plugins.rainbow-delimiters.enable {
            RainbowDelimiterRed = { fg = mkRaw "base09"; };
            RainbowDelimiterYellow = { fg = mkRaw "base0A"; };
            RainbowDelimiterBlue = { fg = mkRaw "base0B"; };
            RainbowDelimiterOrange = { fg = mkRaw "base0C"; };
            RainbowDelimiterGreen = { fg = mkRaw "base0D"; };
            RainbowDelimiterViolet = { fg = mkRaw "base0E"; };
            RainbowDelimiterCyan = { fg = mkRaw "base0F"; };
          })

          # See `lsp-highlight` help section for more details.
          (lib.mkIf config.plugins.lsp.enable {
            LspDiagnosticsDefaultError = { fg = mkRaw "base08"; };
            LspDiagnosticsDefaultWarning = { fg = mkRaw "base09"; };
            LspDiagnosticsDefaultHint = { fg = mkRaw "base0A"; };
            LspDiagnosticsDefaultInformation = { fg = mkRaw "base0B"; };
          })

          # See `treesitter-highlight-groups` help section for more details.
          (lib.mkIf config.plugins.treesitter.enable {
            "${sym "@variable"}" = { __unkeyed = mkRaw "Normal"; };
            "${sym "@tag.delimiter"}" = { fg = mkRaw "base0A"; };
            "${sym "@text.emphasis"}" = { __unkeyed = mkRaw "Italic"; };
            "${sym "@text.underline"}" = { __unkeyed = mkRaw "Underlined"; };
            "${sym "@text.strike"}" = { gui = "strikethrough"; };
            "${sym "@text.uri"}" = { fg = mkRaw "base0C"; };
          })
        ];
      }) config.tinted-theming.schemes;
  };
}
