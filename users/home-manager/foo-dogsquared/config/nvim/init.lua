-- Aliases
local api = vim.api
local g, b = vim.g, vim.b
local cmd = vim.cmd
local highlight = vim.highlight
local opt, opt_local = vim.opt, vim.opt_local
local go = vim.go
local map = vim.api.nvim_set_keymap
local fn = vim.fn

g['mapleader'] = " "
g['syntax'] = true

-- Bootstrapping for the package manager
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  api.nvim_command('packadd packer.nvim')
end

cmd [[packadd packer.nvim]]
-- Plugins
require("packer").startup(function()
  -- Let the package manager manage itself.
  use { "wbthomason/packer.nvim", opt = true }

  -- Custom color themes!
  use { "rktjmp/lush.nvim" }

  -- EditorConfig plugin
  use { "editorconfig/editorconfig-vim" }

  -- Colorize common color strings
  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end
  }

  -- A snippets engine.
  -- One of the must-haves for me.
  use {
    "sirver/ultisnips",
    config = function()
      vim.g.UltiSnipsEditSplit = "context"
      vim.g.UltiSnipsSnippetDirectories = {vim.env.HOME .. "/.config/nvim/own-snippets", ".snippets"}
    end,

    -- Contains various snippets for UltiSnips.
    requires = "honza/vim-snippets"
  }

  -- Text editor integration for the browser
  use {"subnut/nvim-ghost.nvim", run = ":call nvim_ghost#installer#install()"}

  -- Fuzzy finder of lists
  use {
    "nvim-telescope/telescope.nvim",
    config = function()
        vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope grep_string<cr>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>fG', '<cmd>Telescope live_grep<cr>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true })
    end,
    requires = { {"nvim-lua/popup.nvim"}, {"nvim-lua/plenary.nvim"} }
  }

  -- Marks in ~~steroids~~ coconut oil
  use {
      "ThePrimeagen/harpoon",
      config = function()
        vim.api.nvim_set_keymap("n", "<leader>fm", "<cmd>lua require('harpoon.mark').add_file()<cr>", {})
        vim.api.nvim_set_keymap("n", "<leader>fM", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {})
      end,
      requires = { {"nvim-lua/plenary.nvim"} }
  }

  -- A completion engine.
  -- nvim-cmp is mostly explicit by making the configuration process manual unlike bigger plugins like CoC
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "quangnguyen30192/cmp-nvim-ultisnips",
    },
    config = function()
      local cmp = require("cmp")

      local has_any_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
          return false
        end

        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local press = function(key)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "n", true)
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            fn["UltiSnips#Anon"](args.body)
          end,
        },

        sources = {
          { name = "ultisnips" },
          { name = "buffer" },
          { name = "path" },
          { name = "nvim_lua" },
          { name = "nvim_lsp" },
        },

        mapping = {
          ["<C-Space>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if fn["UltiSnips#CanExpandSnippet"]() == 1 then
                return press("<C-R>=UltiSnips#ExpandSnippet()<CR>")
              end

              cmp.select_next_item()
            elseif has_any_words_before() then
              press("<Space>")
            else
              fallback()
            end
          end, {
          "i",
          "s",
        }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.get_selected_entry() == nil and vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
            press("<C-R>=UltiSnips#ExpandSnippet()<CR>")
          elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
            press("<ESC>:call UltiSnips#JumpForwards()<CR>")
          elseif cmp.visible() then
            cmp.select_next_item()
          elseif has_any_words_before() then
            press("<Tab>")
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if fn["UltiSnips#CanJumpBackwards"]() == 1 then
          press("<C-R>=UltiSnips#JumpBackwards()<CR>")
        elseif cmp.visible() then
          cmp.select_previous_item()
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
    }})
  end
  }

  -- A linting engine, a DAP client, and an LSP client entered into a bar.
  use { "dense-analysis/ale" }
  use { "neovim/nvim-lspconfig" }
  use { "mfussenegger/nvim-dap" }
  use { "puremourning/vimspector" }

  -- One of the most popular plugins.
  -- Allows to create more substantial status bars.
  use { "vim-airline/vim-airline" }

  -- Fuzzy finder for finding files freely and fastly.
  use {
    "junegunn/fzf",
    requires = "junegunn/fzf.vim"
  }

  -- A full LaTeX toolchain plugin for Vim.
  -- Also a must-have for me since writing LaTeX can be a PITA.
  -- Most of the snippets and workflow is inspired from Gilles Castel's posts (at https://castel.dev/).
  use {
    "lervag/vimtex",
    cmd = "ALEEnable",
    config = function()
      -- Vimtex configuration
      g["tex_flavor"] = "latex"
      g["vimtex_view_method"] = "zathura"
      g["vimtex_quickfix_mode"] = 0
      g["tex_conceal"] = "abdmg"
      g["vimtex_compiler_latexmk"] = {
        options = {
          "-bibtex",
          "-shell-escape",
          "-verbose",
          "-file-line-error",
        }
      }

      -- I use LuaLaTeX for my documents so let me have it as the default, please?
      g["vimtex_compiler_latexmk_engines"] = {
        _                = "-lualatex",
        pdflatex         = "-pdf",
        dvipdfex         = "-pdfdvi",
        lualatex         = "-lualatex",
        xelatex          = "-xelatex",
      }
    end
  }

  -- Enable visuals for addition/deletion of lines in the gutter (side) similar to Visual Studio Code.
  use { "airblade/vim-gitgutter" }

  -- Language plugins.
  use { "LnL7/vim-nix" }
  use { "vmchale/dhall-vim" }
end)

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = fn.col('.') - 1
  if col == 0 or fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

-- Editor configuration
opt.completeopt = "menuone,noselect"
opt.termguicolors = true
opt.encoding = "utf-8"
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.conceallevel = 1
opt.list = true
opt.listchars = { tab = "   ", trail = "·" }
opt_local.spell = true
opt.smartindent = true

-- I have yet to solve how to do the following in Lua, lmao
cmd "highlight clear SpellBad"
cmd "highlight clear SpellLocal"
cmd "highlight clear SpellCap"
cmd "highlight clear SpellRare"
cmd "highlight CursorLineNr ctermfg=cyan"
cmd "highlight Visual term=reverse cterm=reverse"
cmd "colorscheme fds-theme"

-- Keybindings
map('i', 'jk', '<Esc>', {})
map('n', '<leader>hr', '<cmd>source $MYVIMRC<cr>', {})
map('i', "<Tab>", "v:lua.tab_complete()", { expr = true })
map('s', "<Tab>", "v:lua.tab_complete()", { expr = true })
map('i', "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
map('s', "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })

-- Activating my own modules ala-Doom Emacs.
require('lsp-user-config').setup()
