-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin definitions
local plugins = {
  -- UI & Theme
  theme = {
    "ellisonleao/gruvbox.nvim", -- Gruvbox colorscheme
    priority = 1000,
    config = function()
      require("gruvbox").setup()
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- File Navigation & Search
  fuzzy_finder = {
    "ibhagwan/fzf-lua", -- Fast fuzzy finder for files and text
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({})
    end,
  },

  workspaces = {
    "natecraddock/workspaces.nvim", -- Project workspace management
    config = function()
      require("workspaces").setup({
        hooks = {
          open = "FzfLua files",
        }
      })
    end,
  },

  -- Syntax & Parsing
  treesitter = {
    "nvim-treesitter/nvim-treesitter", -- Advanced syntax highlighting and parsing
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- LSP & Development Tools
  lsp_installer = {
    "williamboman/mason.nvim", -- LSP server package manager
    config = function()
      require("mason").setup()
    end,
  },

  lsp_bridge = {
    "williamboman/mason-lspconfig.nvim", -- Bridge between Mason and LSP config
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "vtsls", "eslint" },
      })
    end,
  },

  lsp_config = {
    "neovim/nvim-lspconfig", -- LSP configuration and setup
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.vtsls.setup({})
      lspconfig.eslint.setup({})
      
      vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<cr>", { desc = "Go to definition" })
      vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<cr>", { desc = "Go to references" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
    end,
  },

  -- Autocompletion
  completion = {
    "saghen/blink.cmp", -- Fast autocompletion engine with LSP support
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    config = function()
      require("blink.cmp").setup({
        keymap = { preset = "default" },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono"
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
      })
    end,
  },

  -- Terminal
  terminal = {
    "akinsho/toggleterm.nvim", -- Floating terminal management
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })
    end,
  },
}

-- Convert plugin table to lazy.nvim format
local plugin_list = {}
for _, plugin_config in pairs(plugins) do
  table.insert(plugin_list, plugin_config)
end

-- Setup lazy.nvim
require("lazy").setup(plugin_list)

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Line numbers
vim.opt.number = true

-- Indentation settings
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.tabstop = 2          -- Tab width when reading existing tabs
vim.opt.shiftwidth = 2       -- Indentation width for >> << and auto-indent
vim.opt.softtabstop = 2      -- Tab width when editing (backspace behavior)

-- Map jj to escape in insert mode
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', {noremap = true, silent = true})

-- System clipboard keymaps
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Auto-reload files changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

-- Notification when file is reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File reloaded due to external change", vim.log.levels.INFO)
  end,
})

-- fzf-lua keymaps
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fG", "<cmd>FzfLua grep_cword<cr>", { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers" })

-- workspaces keymap
vim.keymap.set("n", "<leader>fw", function()
  local workspaces = require("workspaces")
  local fzf = require("fzf-lua")
  
  local workspace_list = workspaces.get()
  local workspace_names = {}
  for _, ws in ipairs(workspace_list) do
    table.insert(workspace_names, ws.name .. " (" .. ws.path .. ")")
  end
  
  fzf.fzf_exec(workspace_names, {
    prompt = "Workspaces> ",
    actions = {
      ['default'] = function(selected)
        local name = selected[1]:match("^(.+)%s%(")
        workspaces.open(name)
      end
    }
  })
end, { desc = "Open workspace" })

-- GitHub line opener keymap
vim.keymap.set("n", "<leader>gh", function()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
  local remote_url = vim.fn.system("git remote get-url origin"):gsub("\n", "")
  
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end
  
  local relative_file = file:sub(#git_root + 2)
  local github_url = remote_url:gsub("git@github.com:", "https://github.com/"):gsub("%.git$", "")
  local full_url = github_url .. "/blob/master/" .. relative_file .. "#L" .. line
  
  vim.fn.system("open -a 'Google Chrome' '" .. full_url .. "'")
  vim.notify("Opened in Chrome: " .. full_url, vim.log.levels.INFO)
end, { desc = "Open current line on GitHub in Chrome" })

-- Custom command to reload init.lua
vim.api.nvim_create_user_command('Reload', function()
  local init_path = vim.fn.stdpath('config') .. '/init.lua'
  vim.cmd('source ' .. init_path)
  vim.notify('Config reloaded!', vim.log.levels.INFO)
end, { desc = 'Reload neovim configuration' })

-- Auto-open workspace selector on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only show workspace selector if no files were opened
    if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 then
      vim.defer_fn(function()
        local workspaces = require("workspaces")
        local fzf = require("fzf-lua")
        
        local workspace_list = workspaces.get()
        local workspace_names = {}
        for _, ws in ipairs(workspace_list) do
          table.insert(workspace_names, ws.name .. " (" .. ws.path .. ")")
        end
        
        fzf.fzf_exec(workspace_names, {
          prompt = "Workspaces> ",
          actions = {
            ['default'] = function(selected)
              local name = selected[1]:match("^(.+)%s%(")
              workspaces.open(name)
            end
          }
        })
      end, 100) -- Small delay to ensure plugins are loaded
    end
  end,
})