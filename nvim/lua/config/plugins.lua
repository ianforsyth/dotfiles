local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Installing my plugins
return packer.startup(function(use)
  use "nvim-lua/plenary.nvim" -- Lua functions, other plugins depend on this
  use "wbthomason/packer.nvim" -- Have packer manage itself

  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim

  use "ellisonleao/gruvbox.nvim" -- Colorscheme

  -- Telescope
  use "nvim-telescope/telescope.nvim"
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- Better sorting in telescope results

  -- Treesitter
  use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }

  -- Commenting
  use "numToStr/Comment.nvim"
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  -- Snippets
  use "SirVer/ultisnips"

  -- Git
  use "lewis6991/gitsigns.nvim"
  use "tpope/vim-fugitive"
  use "tpope/vim-rhubarb"

  -- Explorer
  -- use { 'kyazdani42/nvim-tree.lua', requires = { 'kyazdani42/nvim-web-devicons' }, { tag = 'nightly' } }

  -- Bufferline and status line
  use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}
  use {'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true } }

  -- Workspaces
  use 'natecraddock/workspaces.nvim'

  -- ToggleTerm
  use "akinsho/toggleterm.nvim"

  -- File explorer
  use "preservim/nerdtree"

  use {
    'rmagatti/goto-preview',
    config = function()
      require('goto-preview').setup()
    end
  }

  use { 'goolord/alpha-nvim' }

  use {'neoclide/coc.nvim', branch = 'release'}

  -- Language specific syntax
  use {'elubow/cql-vim'} -- Cassandra CQL
  use {'solarnz/thrift.vim'} -- Thrift interface

  -- Test runner
  use {'vim-test/vim-test' }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
