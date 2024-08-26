---------------------------------------------------------------------------------
-- TOP LEVEL
---------------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set
local fn = vim.fn

----------------------------------
-- INSTALL LAZY ------------------
----------------------------------
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

---------------------------------------------------------------------------------
-- PLUGINS
---------------------------------------------------------------------------------
local plugins = {
  cmp = "hrsh7th/nvim-cmp",
  floaterm = "voldikss/vim-floaterm",
  vim_test = "vim-test/vim-test",
  openingh = "almo7aya/openingh.nvim",
  triptych = "simonmclean/triptych.nvim",
  comment = "numToStr/Comment.nvim",
  dashboard = "nvimdev/dashboard-nvim",
  sessions = "natecraddock/sessions.nvim",
  workspaces = "natecraddock/workspaces.nvim",
  lspconfig = "neovim/nvim-lspconfig",
  treesitter = "nvim-treesitter/nvim-treesitter",
  lspsaga = "nvimdev/lspsaga.nvim",
  bufferline = "akinsho/bufferline.nvim",
  telescope = "nvim-telescope/telescope.nvim",
  gruvbox = "ellisonleao/gruvbox.nvim",
  metals = "scalameta/nvim-metals",
  gitsigns = "lewis6991/gitsigns.nvim",
  lsp_lines = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  snippets = "L3MON4D3/LuaSnip", 
  cmp_snippets = "saadparwaiz1/cmp_luasnip", 
}

require("lazy").setup({
  {
    plugins.comment,
    config = function()
      require('Comment').setup()
    end,
  },
  {
    plugins.cmp,
    event = "InsertEnter", -- Lazy-load on entering insert mode
    dependencies = {
      plugins.snippets,
      plugins.cmp_snippets,
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",   -- Buffer source for nvim-cmp
      "hrsh7th/cmp-path",     -- Path source for nvim-cmp
      "rafamadriz/friendly-snippets", -- A collection of snippets for multiple languages
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-1),
          ['<C-f>'] = cmp.mapping.scroll_docs(1),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' }
        })
      })

      require("luasnip.loaders.from_vscode").lazy_load()
      require("snippets")
    end
  },
  plugins.floaterm,
  plugins.vim_test,
  plugins.openingh,
  {
    plugins.triptych,
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require 'triptych'.setup({
        options = {
          show_hidden = true
        }
      })
    end
  },
  {
    plugins.dashboard,
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        -- config
      }
    end,
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
  },
  {
    plugins.sessions,
    config = function()
      require("sessions").setup()
    end
  },
  {
    plugins.workspaces,
    config = function()
      local sessions = require("sessions")
      -- IF (4/3/24) Needed to find the path to the symlinked directory
      local config_path = vim.loop.fs_realpath(vim.fn.stdpath('config'))

      require("workspaces").setup({
        path = config_path .. "/workspaces",
        hooks = {
          open_pre = function()
            sessions.stop_autosave()
            vim.cmd("silent %bdelete!")
          end,
          open = function()
            local current_workspace = require("workspaces").name()
            local session_path = config_path .. "/sessions/" .. current_workspace .. "_session.vim"

            if vim.loop.fs_stat(session_path) then
              sessions.load(session_path)
            else
              sessions.save(session_path)
            end
            _G.open_dashboard_if_no_buffers()
          end,
        }
      })
    end
  },
  {
    plugins.lspconfig,
    config = function()
      require'lspconfig'.tsserver.setup{} -- Typescript
      require'lspconfig'.solargraph.setup{} -- Ruby
    end,
    init = function()
      vim.fn.system([[command -v typescript-language-server >/dev/null 2>&1 || npm install -g typescript-language-server typescript]])
      vim.fn.system([[gem list -i solargraph >/dev/null || gem install solargraph]])
    end
  },
  {
    plugins.treesitter,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { 
          "lua",
          "markdown", 
          "markdown_inline", 
          "scala",
          "thrift"
        },
        highlight = {
          enable = true,
        },
      }
    end,
  },
  {
    plugins.lspsaga,
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons'    
    },
    config = function()
      require('lspsaga').setup({
        definition = {
          keys = {
            close = 'gc'
          }
        },
        lightbulb = {
          enable = false 
        }
      })
    end
  },
  {
    plugins.bufferline, 
    version = "*", 
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup({
        options = {
          diagnostics = "nvim_lsp",
          show_close_icon = false
        }
      })
    end
  },
  {
    plugins.telescope,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup{
        defaults = {
            file_ignore_patterns = { ".git/" },
            path_display = {"truncate"},
        }
      }
    end
  },
  { 
    plugins.gruvbox, 
    priority = 1000 , 
    -- TODO (4/1/24): Go through these config options and remove unused/unwanted ones
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.cmd("colorscheme gruvbox")
    end
  },
  {
    plugins.metals,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
      local metals_config = require("metals").bare_config()
      metals_config.on_attach = function(client, bufnr)
        -- your on_attach function
      end

      metals_config.settings = {
        autoImportBuild = "all",
        defaultBspToBuildTool = true,
      }

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = self.ft,
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end
  },
  {
    plugins.gitsigns,
    config = function()
      require('gitsigns').setup()
    end,
  },
  {
    plugins.lsp_lines,
    config = function()
      require("lsp_lines").setup()
    end,
  }
})

---------------------------------------------------------------------------------
-- CUSTOM FUNCTIONS
---------------------------------------------------------------------------------
function _G.open_dashboard_if_no_buffers()
    local buffers = vim.api.nvim_list_bufs()
    local buffer_loaded = false

    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= "" then
            buffer_loaded = true
            break
        end
    end

    if not buffer_loaded then
        vim.cmd("Dashboard")
    end
end

function _G.create_and_open_file()
  local current_dir = vim.fn.expand('%:p:h')
  -- Input prompt for the new file name
  local new_file = vim.fn.input('Enter new file name: ', current_dir .. '/', 'file')
  -- Check if input was cancelled with <Ctrl>-c
  if new_file == "" then
    print("File creation cancelled.")
    return
  end
  -- Proceed only if the file name is not empty (avoiding <Ctrl>-c case)
  if vim.fn.filereadable(new_file) == 0 then
      local uv = vim.loop
      local fd = uv.fs_open(new_file, "w", 438) -- 438 is octal for 0666
      if fd then uv.fs_close(fd) else print("Error creating file.") return end
  end
  vim.cmd('edit ' .. new_file)
end

function _G.delete_current_file()
  -- Get the name of the current file
  local file = vim.fn.expand('%')
  -- Check if there is a file associated with the buffer
  if file == "" or vim.fn.filereadable(file) == 0 then
    print("No file to delete.")
    return
  end
  -- Ask for confirmation
  local confirm = vim.fn.confirm("Are you sure you want to delete this file? " .. file, "&Yes\n&No", 2)
  if confirm == 1 then
    -- User confirmed deletion, proceed
    os.remove(file)
    -- Close the buffer without saving
    vim.cmd('bdelete!')
    print("Deleted file: " .. file)
  else
    -- User canceled deletion
    print("File deletion cancelled.")
  end
end

function _G.open_in_finder()
  local file_path = vim.fn.expand('%:p')  -- Get the full path of the current file
  if file_path ~= '' then
    vim.cmd('silent !open -R ' .. vim.fn.shellescape(file_path))
  else
    print('Cannot open Finder: No file selected')
  end
end

---------------------------------------------------------------------------------
-- AUTOCMDS AND NATIVE CONFIGS
---------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        -- Delay the execution to ensure all startup processes complete
        vim.defer_fn(function() _G.open_dashboard_if_no_buffers() end, 100)
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    pattern = "*",
    callback = function()
        -- Use a small delay to ensure the buffer list is updated before checking
        vim.defer_fn(function() _G.open_dashboard_if_no_buffers() end, 100)
    end,
})
-- IF (4/2/24) Always enter a terminal in insert mode
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.cmd("startinsert!")
    end
  end
})

-- IF (4/3/24) Reload buffers changed externally
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function(args)
    vim.cmd('checktime')
    vim.notify("Buffer reloaded due to external change: " .. args.file, vim.log.levels.INFO)
  end,
})

vim.diagnostic.config({
  virtual_text = false,
})


---------------------------------------------------------------------------------
-- KEYMAPS
---------------------------------------------------------------------------------
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', {noremap = true})
vim.api.nvim_set_keymap('t', 'jj', '<C-\\><C-n>', {noremap = true})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files({ hidden = true })
end, { noremap = true, silent = true, desc = "File explorer, showing hidden files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fG', builtin.grep_string, {})
vim.api.nvim_set_keymap('n', '<leader>w', ':Telescope workspaces<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fd', ':lua _G.delete_current_file()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fd', ':lua _G.delete_current_file()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fn', ':lua _G.create_and_open_file()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fs', ':lua _G.open_in_finder()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>fe', ':Triptych<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>en', function()
  vim.diagnostic.goto_next({float = false})
end, { noremap = true, silent = true, desc = "Go to next diagnostic without float" })


vim.keymap.set("n", "<leader>x", ":%bd!|e#|bd#<CR>", { noremap = true, silent = true }) -- Close all buffers except current

vim.keymap.set({"n", "v"}, "gh", ":OpenInGHFileLines!<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "gf", ":Lspsaga finder<CR>", {noremap=true, silent=true})
vim.keymap.set("n", "gd", ":Lspsaga peek_definition<CR>", {noremap=true, silent=true})
vim.keymap.set("n", "gt", ":Lspsaga hover_doc<CR>", {noremap=true, silent=true})

vim.keymap.set('n', '<C-\\>', ':FloatermToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>:FloatermToggle<CR>', { noremap = true, silent = true })

vim.keymap.set('n', 'tn', ":TestNearest<CR>", { noremap = true, silent = true })
vim.keymap.set('n', 'tl', ":TestLast<CR>", { noremap = true, silent = true })
vim.keymap.set('n', 'tf', ":TestFile<CR>", { noremap = true, silent = true })
vim.keymap.set('n', 'ts', ":TestSuite<CR>", { noremap = true, silent = true })

-- Navigate buffers
vim.keymap.set("n", "<C-l>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer"})
vim.keymap.set("n", "<C-h>", ":bprev<CR>", { noremap = true, silent = true, desc = "Next buffer"})

---------------------------------------------------------------------------------
-- OPTIONS
---------------------------------------------------------------------------------
local options = {
  backup = false,                          -- prevents backup files from being created
  hlsearch = true,                         -- highlight all matches on previous search pattern
  ignorecase = true,                       -- ignore case in search patterns
  smartcase = true,                        -- smart case
  smartindent = true,                      -- make indenting smarter again
  expandtab = true,                        -- convert tabs to spaces
  shiftwidth = 2,                          -- the number of spaces inserted for each indentation
  tabstop = 2,                             -- insert 2 spaces for a tab
  swapfile = false,                        -- prevents a swapfile
  termguicolors = true,                    -- set term gui colors (most terminals support this)
  -- timeoutlen = 1000,                       -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true,                         -- enable persistent undo
  -- updatetime = 300,                        -- faster completion (4000ms default)
  cursorline = true,                       -- highlight the current line
  number = true,                           -- set numbered lines
  signcolumn = "number",                   -- show signs over the top of line numbers
  scrolloff = 10,                           -- extra room below the end of a file
  -- guifont = "monospace:h17",               -- the font used in graphical neovim applications
}

-- IF (4/2/24): Not sure if this is needed, copied over from nvim-metals minimal config example
vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }

for k, v in pairs(options) do
  vim.opt[k] = v
end
