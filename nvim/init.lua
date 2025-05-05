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
  -- Use `:Lazy update` to persist changes
  cmp = "hrsh7th/nvim-cmp",
  floaterm = "voldikss/vim-floaterm",
  openingh = "almo7aya/openingh.nvim", -- Opens the current file or project page in GitHub
  explorer = "simonmclean/triptych.nvim",
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
  gitsigns = "lewis6991/gitsigns.nvim",
  lsp_lines = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  snippets = "L3MON4D3/LuaSnip",
  cmp_snippets = "saadparwaiz1/cmp_luasnip",
  noice = "folke/noice.nvim", -- Pop outs for cmd and search, notifications
}

require("lazy").setup({
  {
    plugins.comment,
    event = "VeryLazy", -- Load late in the startup sequence
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
      "hrsh7th/cmp-cmdline",  -- Command line source for nvim-cmp
      "rafamadriz/friendly-snippets", -- A collection of snippets for multiple languages
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        -- Highlights first option
        completion = {
          completeopt = 'menu,menuone,noinsert'
        },
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

      cmp.setup.cmdline({'/', '?'}, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      require("luasnip.loaders.from_vscode").lazy_load()
      require("snippets")
    end
  },
  {
    plugins.floaterm,
    cmd = "FloatermToggle", -- Load when FloatermToggle command is used
  },
  {
    plugins.openingh,
    cmd = "OpenInGHFileLines", -- Load when OpenInGHFileLines command is used
  },
  {
    plugins.explorer,
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
    end,
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
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
    event = "VeryLazy", -- Load late in the startup sequence
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
      require'lspconfig'.ts_ls.setup{} -- Typescript
      require'lspconfig'.solargraph.setup{} -- Ruby
    end,
  },
  {
    plugins.treesitter,
    build = ":TSUpdate",
    event = "VeryLazy", -- Load late in the startup sequence
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
    event = "VeryLazy", -- Load late in the startup sequence
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
    event = "VeryLazy", -- Load late in the startup sequence
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
    cmd = "Telescope", -- Load when Telescope command is used
    keys = { "<leader>ff", "<leader>fg", "<leader>fG", "<leader>w" }, -- Also load on keymaps
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
    plugins.gitsigns,
    event = "VeryLazy", -- Load late in the startup sequence
    config = function()
      require('gitsigns').setup()
    end,
  },
  {
    plugins.lsp_lines,
    event = "VeryLazy", -- Load late in the startup sequence
    config = function()
      require("lsp_lines").setup()
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "claude",
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
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

-- IF (8/29/24): Remove trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = "%s/\\s\\+$//e",
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
vim.api.nvim_set_keymap('n', '<leader>fn', ':lua _G.create_and_open_file()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fs', ':lua _G.open_in_finder()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fe', ':Triptych<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>en', function()
  vim.diagnostic.goto_next({float = false})
end, { noremap = true, silent = true, desc = "Go to next diagnostic without float" })

vim.keymap.set("n", "<leader>x", ":%bd!|e#|bd#<CR>", { noremap = true, silent = true, desc = "Close all buffers except current" })

vim.keymap.set({"n", "v"}, "gh", ":OpenInGHFileLines!<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "gf", ":Lspsaga finder<CR>", {noremap=true, silent=true})
vim.keymap.set("n", "gd", ":Lspsaga peek_definition<CR>", {noremap=true, silent=true})
vim.keymap.set("n", "gt", ":Lspsaga hover_doc<CR>", {noremap=true, silent=true})
vim.keymap.set("n", "ga", ":Lspsaga code_action<CR>", {noremap=true, silent=true})

vim.keymap.set('n', '<C-\\>', ':FloatermToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>:FloatermToggle<CR>', { noremap = true, silent = true })

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
  undofile = true,                         -- enable persistent undo
  cursorline = true,                       -- highlight the current line
  number = true,                           -- set numbered lines
  signcolumn = "number",                   -- show signs over the top of line numbers
  scrolloff = 10,                           -- extra room below the end of a file
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
