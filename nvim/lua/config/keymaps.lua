local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Cycle through windows
keymap("n", "<leader>c", "<C-w>W", opts)

-- Save and escape
keymap("i", "jj", "<ESC>:w<CR>", opts)

-- Move text up and down
keymap("n", "<C-j>", ":m +1<CR>==", opts)
keymap("n", "<C-k>", ":m -2<CR>==", opts)

-- LSP shortcuts
keymap('n', "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", opts)
keymap('n', "gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)

-- Telescope
keymap("n", "<leader>t", "<cmd>Telescope find_files<CR>", opts)
keymap("n", "<leader>f", "<cmd>Telescope live_grep<CR>", opts)
keymap("n", "<leader>F", "<cmd>Telescope grep_string<CR>", opts)
keymap("n", "<leader>w", "<cmd>Telescope workspaces<CR>", opts)

-- Toggle Nvimtree explorer
keymap("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<CR>", opts)

-- Navigate buffers
keymap("n", "<C-l>", ":bnext<CR>", opts)
keymap("n", "<C-h>", ":bprevious<CR>", opts)
--[[ keymap("n", "<leader>q", ":Bdelete<CR>", opts) -- Close buffer ]] -- Can remove this later if the current version works for a while
keymap("n", "<leader>q", ":bp<CR>:bd#<CR>", opts) -- Close buffer and preserve window
keymap("n", "<leader>x", ":BufferLineCloseLeft<CR>:BufferLineCloseRight<CR>", opts) -- Close all but active buffer
