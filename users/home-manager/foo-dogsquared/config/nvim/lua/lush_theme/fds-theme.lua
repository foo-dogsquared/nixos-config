-- CREDITS: pwntester/nautilus.nvim
local lush = require('lush')
local hsl = lush.hsl

--[[
    base00 - Default Background
    base01 - Lighter Background (Used for status bars)
    base02 - Selection Background
    base03 - Comments, Invisibles, Line Highlighting
    base04 - Dark Foreground (Used for status bars)
    base05 - Default Foreground, Caret, Delimiters, Operators
    base06 - Light Foreground (Not often used)
    base07 - Light Background (Not often used)
    base08 - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 - Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A - Classes, Markup Bold, Search Text Background
    base0B - Strings, Inherited Class, Markup Code, Diff Inserted
    base0C - Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D - Functions, Methods, Attribute IDs, Headings
    base0E - Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0F - Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>

    Alphas are Pantone 534 C = #1B365D
    Alphas legends are TU2 = #00a4a9
    Modifiers are Pantone 533 C = #1F2A44
    Modifiers legends are GMK N6 = #e5a100
    Alternate modifiers are GMK N6 = #e5a100
    Alternate modifiers legends are Pantone 533 C = #1F2A44

    Cello #23395b
    Java #02b3af
    Orient #005880
    Supernova #fbca00
]]--

local base00 = hsl('#2b221f')
local base01 = hsl('#412c26')
local base02 = hsl('#54352c')
local base03 = hsl('#8d5c4c')
local base04 = hsl('#e1bcb2')
local base05 = hsl('#f5ecea')
local base06 = hsl('#fefefe')
local base07 = hsl('#eb8a65')
local base08 = hsl('#d03e68')
local base09 = hsl('#eb914a')
local base0A = hsl('#afa644')
local base0B = hsl('#85b26e')
local base0C = hsl('#df937a')
local base0D = hsl('#a15c40')
local base0E = hsl('#8b7ab9')
local base0F = hsl('#6f3920')

--[[

  Define additional colors if defined in the theme. Fallback to base00 - base07 
  if not defined. 

]]

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

return lush(function() 
  return { 
    Normal { fg = base05, bg = base00 },
    NormalFloat { fg = base05, bg = base01 },
    Bold { gui = 'bold' },
    Debug { fg = base08 },
    Directory { fg = base0D },
    Error { fg = base01, bg = base08 },
    ErrorMsg { fg = base08 },
    Exception { fg = base08 },
    FoldColumn { fg = base03 },
    Folded { fg = base03, bg = base01 },
    Italic { gui = 'italic' },
    Macro { fg = base08 },
    ModeMsg { fg = base0B },
    MoreMsg { fg = base0B },
    Question { fg = base0D },
    Search { fg = base00, bg = base04 },
    IncSearch { fg = base00, bg = base09 },
    Substitute { fg = base01, bg = base0A },
    SpecialKey { fg = base03 },
    TooLong { fg = base08 },
    Underlined { fg = base08 },
    Visual { bg = base02 },
    VisualNOS { fg = base08 },
    WarningMsg { fg = base08 },
    WildMenu { fg = base08, bg = base0A },
    Title { fg = base0D },
    Conceal { fg = base0D },
    Cursor { fg = base00, bg = base05 },
    NonText { fg = base03 },
    LineNr { fg = base02, bg = base00 },
    LineNrNC { fg = base02, bg = base01 },
    SignColumn { fg = base01 },
    StatusLine { fg = base02, bg = base01 },
    StatusLineNC { fg = base02, bg = base01 },
    VertSplit { fg = base02, bg = base00 },
    ColorColumn { fg = base01, bg = base01 },
    CursorColumn { bg = base01 },
    CursorLine { bg = base01 },
    CursorLineNr { fg = base0A, bg = base00 },
    QuickFixLine { bg = base00 },
    QFFileName { fg = base0A },
    QFLineNr { fg = base04 },
    PMenu { fg = base05, bg = base01 },
    PMenuSel { fg = base01, bg = base05 },
    TabLineSel { fg = base00, bg = base0A },
    TabLine { fg = base03, bg = base00 },
    TabLineFill { fg = base03, bg = base00 },
    EndOfBuffer { fg = base01 },


    -- Standard syntax highlighting
    Boolean { fg = base09 },
    Character { fg = base08 },
    Comment { fg = base03, gui = "italic" },
    Conditional { fg = base0E },
    Constant { fg = base09 },
    Define { fg = base0E },
    Delimiter { fg = base0F },
    Float { fg = base09 },
    Function { fg = base0D },
    Identifier { fg = base0A },
    Include { fg = base0D },
    Keyword { fg = base0E },
    Label { fg = base0A },
    Number { fg = base03 },
    Operator { fg = base03 },
    PreProc { fg = base0A },
    Repeat { fg = base0A },
    Special { fg = base0C },
    SpecialChar { fg = base0F },
    Statement { fg = base08 },
    StorageClass { fg = base0A },
    String { fg = base0B },
    Structure { fg = base0E },
    Tag { fg = base0A },
    Todo { fg = base0A, bg = base01 },
    Type { fg = base0A },
    Typedef { fg = base0A },

    ---
    -- Extra definitions
    ---

    -- Help
    HelpDoc { fg = base05, bg = base0D, gui = 'bold,italic' },
    HelpIgnore { fg = base0B, gui = 'bold,italic' },

    -- C highlighting
    cOperator { fg = base0C },
    cPreCondit { fg = base0E },

    -- C# highlighting
    csClass { fg = base0A },
    csAttribute { fg = base0A },
    csModifier { fg = base0E },
    csType { fg = base08 },
    csUnspecifiedStatement { fg = base0D },
    csContextualStatement { fg = base0E },
    csNewDecleration { fg = base08 },

    -- CSS highlighting
    cssBraces { fg = base05 },
    cssClassName { fg = base0E },
    cssColor { fg = base0C },

    -- Diff highlighting
    DiffAdd { fg = base0B, bg = base0B.darken(80) },
    DiffAdded { fg = base0B, bg = base0B.darken(80) },
    DiffNewFile { fg = base0B, bg = base0B.darken(80) },

    DiffDelete { fg = base08, bg = base08.darken(80) },
    DiffRemoved { fg = base08, bg = base08.darken(80) },

    DiffChange { fg = base03, bg = base03.darken(60) },
    DiffFile { fg = base03, bg = base03.darken(60) },
    DiffLine { fg = base03, bg = base03.darken(60) },
    DiffText { fg = base03, bg = base03.darken(60) },

    -- Git highlighting
    gitcommitOverflow { fg = base08 },
    gitcommitSummary { fg = base0B },
    gitcommitComment { fg = base03 },
    gitcommitUntracked { fg = base03 },
    gitcommitDiscarded { fg = base03 },
    gitcommitSelected { fg = base03 },
    gitcommitHeader { fg = base0E },
    gitcommitSelectedType { fg = base0D },
    gitcommitUnmergedType { fg = base0D },
    gitcommitDiscardedType { fg = base0D },
    gitcommitBranch { fg = base09, gui = 'bold' },
    gitcommitUntrackedFile { fg = base0A },
    gitcommitUnmergedFile { fg = base08, gui = 'bold' },
    gitcommitDiscardedFile { fg = base08, gui = 'bold' },
    gitcommitSelectedFile { fg = base0B, gui = 'bold' },

    -- GitGutter highlighting
    GitGutterAdd { fg = base0B, bg = base01 },
    GitGutterChange { fg = base0D, bg = base01 },
    GitGutterDelete { fg = base08, bg = base01 },
    GitGutterChangeDelete { fg = base0E, bg = base01 },

    -- HTML highlighting
    htmlBold { fg = base0A },
    htmlItalic { fg = base0E },
    htmlEndTag { fg = base05 },
    htmlTag { fg = base05 },

    -- JavaScript highlighting
    javaScript { fg = base05 },
    javaScriptBraces { fg = base05 },
    javaScriptNumber { fg = base09 },

    -- pangloss/vim-javascript highlighting
    jsOperator { fg = base0D },
    jsStatement { fg = base0E },
    jsReturn { fg = base0E },
    jsThis { fg = base08 },
    jsClassDefinition { fg = base0A },
    jsFunction { fg = base0E },
    jsFuncName { fg = base0D },
    jsFuncCall { fg = base0D },
    jsClassFuncName { fg = base0D },
    jsClassMethodType { fg = base0E },
    jsRegexpString { fg = base0C },
    jsGlobalObjects { fg = base0A },
    jsGlobalNodeObjects { fg = base0A },
    jsExceptions { fg = base0A },
    jsBuiltins { fg = base0A },

    -- Mail highlighting
    mailQuoted1 { fg = base0A },
    mailQuoted2 { fg = base0B },
    mailQuoted3 { fg = base0E },
    mailQuoted4 { fg = base0C },
    mailQuoted5 { fg = base0D },
    mailQuoted6 { fg = base0A },
    mailURL { fg = base0D },
    mailEmail { fg = base0D },

    -- Markdown highlighting
    markdownh1 { fg = base0D, gui = 'bold' },
    markdownh2 { fg = base0D, gui = 'bold' },
    markdownh3 { fg = base0D, gui = 'bold' },
    markdownh4 { fg = base0D, gui = 'bold' },
    markdownh5 { fg = base0D, gui = 'bold' },
    markdownh6 { fg = base0A, gui = 'bold' },
    markdownRule { fg = markdownh2.bg, gui = 'bold' },
    markdownItalic { fg = base05, gui = 'italic' },
    markdownBold { fg = base05, gui = 'bold' },
    markdownBoldItalic { fg = base05, gui = 'bold,italic' },
    markdownCodeDelimiter { fg = base0B, gui = 'bold' },
    markdownCode { fg = base07, bg = base00 },
    markdownCodeBlock { fg = base0B },
    markdownFootnoteDefinition { fg = base05, gui = 'italic' },
    markdownListMarker { fg = base05, gui = 'bold' },
    markdownLineBreak { fg = base08, gui = 'underline' },
    markdownError { fg = base05, bg = base00 },
    markdownHeadingDelimiter { fg = base0D },
    markdownUrl { fg = base09 },
    markdownFootnote { fg = base0E, gui = 'italic' },
    markdownBlockquote { fg = base0C, gui = 'bold' },
    markdownLinkText { fg = base08, gui = 'italic' },

    -- NERDTree highlighting
    NERDTreeDirSlash { fg = base0D },
    NERDTreeExecFile { fg = base05 },

    -- PHP highlighting
    phpMemberSelector { fg = base05 },
    phpComparison { fg = base05 },
    phpParent { fg = base05 },
    phpMethodsVar { fg = base0C },

    -- Python highlighting
    pythonOperator { fg = base0E },
    pythonRepeat { fg = base0E },
    pythonInclude { fg = base0E },
    pythonStatement { fg = base0E },

    -- Ruby highlighting
    rubyAttribute { fg = base0D },
    rubyConstant { fg = base0A },
    rubyInterpolationDelimiter { fg = base0F },
    rubyRegexp { fg = base0C },
    rubySymbol { fg = base0B },
    rubyStringDelimiter { fg = base0B },

    -- SASS highlighting
    sassidChar { fg = base08 },
    sassClassChar { fg = base09 },
    sassInclude { fg = base0E },
    sassMixing { fg = base0E },
    sassMixinName { fg = base0D },

    -- Signify highlighting
    -- SignifySignAdd { fg = base0B, bg = base00 },
    -- SignifySignChange { fg = base03, bg = base00 },
    -- SignifySignDelete { fg = base08, bg = base00 },

    -- Spelling highlighting
    SpellBad { gui = 'undercurl' }, --, base08)
    SpellLocal { gui = 'undercurl' }, --, base0C)
    SpellCap { gui = 'undercurl' }, --, base0D)
    SpellRare { gui = 'undercurl' }, --, base0E)

    -- Startify highlighting
    StartifyBracket { fg = base03 },
    StartifyFile { fg = base07 },
    StartifyFooter { fg = base03 },
    StartifyHeader { fg = base0B },
    StartifyNumber { fg = base09 },
    StartifyPath { fg = base03 },
    StartifySection { fg = base0E },
    StartifySelect { fg = base0C },
    StartifySlash { fg = base03 },
    StartifySpecial { fg = base03 },

    -- Java highlighting
    javaOperator { fg = base0D },

    -- Vim
    -- vimCommand { fg = hue_3, bg =  none },
    -- vimCommentTitle { fg = mono_3, gui = 'bold' },
    -- vimFunction { fg = l.Function, bg =  none },
    -- vimFuncName { fg = hue_3, bg =  none },
    -- vimHighlight { fg = hue_2, bg =  none },
    -- vimLineComment { fg = mono_3, gui = 'italic' },
    -- vimParenSep { fg = mono_2 },
    -- vimSep { fg = mono_2 },
    -- vimUserFunc { fg = hue_1, bg =  none },
    -- vimUserCommand { fg = hue_1, bg =  none },
    -- vimVar { fg = hue_5, bg =  none },

    -- Telescope highlighting
    --TelescopeNormal { fg = base05, bg = base00 },
    TelescopeNormal { fg = base05, bg = base01 },
    TelescopeBorder { fg = base00, bg = base01 },
    TelescopePromptPrefix { fg = base0A, bg = base01 },
    TelescopeMatching { fg = base0D, bg = base01 },
    TelescopeSelection { fg = base0A, bg = base01 },
    TelescopeSelectionCaret { fg = base0A, bg = base01 },

    --LSP highlighting
    LspDiagnosticsDefaultError { fg = base08 },
    LspDiagnosticsDefaultWarning { fg = base09 },
    LspDiagnosticsDefaultHint { fg = base0A },
    LspDiagnosticsDefaultInformation { fg = base0B },

    -- XML highlighting
    xmlTagName { fg = base0D },
    xmlCdatastart { fg = base0A },
    xmlEndTag { fg = xmlTagName.bg },
    xmlCdataCdata { fg = xmlCdatastart.bg },

    -- MatchParen
    MatchParen { fg = base07, bg = base08 },

    -- CodeQL
    CodeqlAstFocus { fg = base00, bg = base03 },

    -- TreeSitter
    TSError { fg = Error.bg, gui = 'bold' },
    TSPunctDelimiter { fg = base05 },
    TSPunctBracket { fg = base05 },
    TSConstant { fg = Constant.fg },
    TSConstBuiltin { fg = Constant.fg },
    TSConstMacro { fg = Constant.fg },
    TSString { fg = String.fg },
    TSStringRegex { fg = base03 },
    TSStringEscape { fg = base03 },
    TSCharacter { fg = Character.fg },
    TSNumber { fg = Number.fg },
    TSBoolean { fg = Boolean.fg },
    TSFloat { fg = Number.fg },
    TSFunction { fg = Function.fg },
    TSFuncBuiltin { fg = Function.fg },
    TSFuncMacro { fg = Function.fg },
    TSParameter { fg = base0D },
    TSConstructor { fg = base0E },
    TSKeywordFunction { fg = base0E },
    TSLiteral { fg = base04, gui = 'bold' },
    TSVariable { fg = base03 },
    TSVariableBuiltin { fg = base0E },
    TSParameterReference { fg = TSParameter.fg },
    TSMethod { fg = Function.fg },
    TSConditional { fg = Conditional.fg },
    TSRepeat { fg = Repeat.fg },
    TSLabel { fg = Label.fg },
    TSOperator { fg = Operator.fg },
    TSKeyword { fg = Keyword.fg },
    TSException { fg = Exception.fg },
    TSType { fg = Type.fg },
    TSTypeBuiltin { fg = Type.fg },
    TSStructure { fg = Structure.fg },
    TSInclude { fg = Include.fg },
    TSAnnotation { fg = base03 },
    TSStrong { fg = base05, bg = base00, gui = 'bold' },
    TSTitle { fg = base0D },

    -- Diff highlighting
    GitSignsAdd { fg = base0B, },
    GitSignsDelete { fg = base08 },
    GitSignsChange { fg = base03 },

    -- Indent-Blank-Lines
    IndentGuide { fg = base01 },
  }
end)
