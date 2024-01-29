local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Cycle through windows
keymap("n", "<leader>c", "<C-w>W", opts)

-- Resize split widths
keymap("n", "<C-.>", "20<C-w>>", opts)
keymap("n", "<C-,>", "20<C-w><", opts)

-- Save and escape
keymap("i", "jj", "<ESC>:w<CR>", opts)

-- Move text up and down
keymap("n", "<C-j>", ":m +1<CR>==", opts)
keymap("n", "<C-k>", ":m -2<CR>==", opts)

-- Telescope
keymap("n", "<leader>t", "<cmd>Telescope find_files<CR>", opts)
keymap("n", "<leader>f", "<cmd>Telescope live_grep<CR>", opts)
keymap("n", "<leader>F", "<cmd>Telescope grep_string<CR>", opts)
keymap("n", "<leader>w", "<cmd>Telescope workspaces<CR>", opts)

-- Vim Test
keymap("n", "tf", "<cmd>TestFile<CR>", opts)
keymap("n", "tl", "<cmd>TestLast<CR>", opts)
keymap("n", "tn", "<cmd>TestNearest<CR>", opts)

-- Toggle file explorer
-- keymap("n", "<leader>e", "<cmd>NERDTreeFind<CR>", opts)
keymap("n", "<leader>e", "g:NERDTree.IsOpen() ? '<cmd>NERDTreeClose<CR>' : bufexists(expand('%')) ? '<cmd>NERDTreeFind<CR>' : '<cmd>NERDTree<CR>'", {silent = true, expr = true, noremap = true})

-- Navigate buffers
keymap("n", "<C-l>", ":bnext<CR>", opts)
keymap("n", "<C-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>q", ":bw<CR>", opts) -- Close buffer and preserve window
keymap("n", "<leader>x", ":%bd<CR>", opts) -- Close all buffers

-- LSP
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
        cmd('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        cmd('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end

function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- keymap("n", "gd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", opts)
 keymap("n", "gtd", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", opts)
-- keymap("n", "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", opts)
-- keymap("n", "gt", "<cmd>lua vim.lsp.buf.hover()()<CR>", opts)
keymap("n", "gd", "<Plug>(coc-definition)", opts)
keymap("n", "gtd", "<Plug>(coc-type-definition)", opts)
keymap("n", "gt", "<CMD>lua _G.show_docs()<CR>", opts)
keymap("n", "gb", "<CMD>.GBrowse<CR>", opts)
-- keymap('n', "gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)

keymap("n", "ge", "<cmd>lua vim.diagnostic.goto_next { wrap = true }<CR>", opts)
keymap("n", "gn", '<cmd>Gitsigns next_hunk<CR>', opts)

-- nmap <silent> [g <Plug>(coc-diagnostic-prev)
-- nmap <silent> ]g <Plug>(coc-diagnostic-next)
--
-- " Use K to show documentation in preview window.
-- nnoremap <silent> K :call ShowDocumentation()<CR>

vim.g.coc_snippet_next = '<tab>'
vim.api.nvim_set_keymap(
  'i', 
  '<Tab>', 
  'pumvisible() ? coc#_select_confirm() : coc#expandableOrJumpable() ? "<C-r>=coc#rpc#request(\'doKeymap\', [\'snippets-expand-jump\',\'\'])<CR>" : v:lua.check_backspace() ? "<Tab>" : coc#refresh()', 
  { expr = true, silent = true }
)


-- keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
-- keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
-- keymap("n", "gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
-- keymap("n", "gws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
-- keymap("n", "<leader>cl", [[<cmd>lua vim.lsp.codelens.run()<CR>]], opts)
-- keymap("n", "<leader>sh", [[<cmd>lua vim.lsp.buf.signature_help()<CR>]], opts)
-- keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
-- keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>")
-- keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
-- keymap("n", "<leader>ws", '<cmd>lua require"metals".hover_worksheet()<CR>', opts)
-- keymap("n", "<leader>aa", [[<cmd>lua vim.diagnostic.setqflist()<CR>]], opts) -- all workspace diagnostics
-- keymap("n", "<leader>ae", [[<cmd>lua vim.diagnostic.setqflist({severity = "E"})<CR>]], opts) -- all workspace errors
-- keymap("n", "<leader>aw", [[<cmd>lua vim.diagnostic.setqflist({severity = "W"})<CR>]], opts) -- all workspace warnings
-- keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts) -- buffer diagnostics only
-- keymap("n", "[c", "<cmd>lua vim.diagnostic.goto_prev { wrap = false }<CR>", opts)

-- Example mappings for usage with nvim-dap. If you don't use that, you can
-- skip these
-- map("n", "<leader>dc", [[<cmd>lua require"dap".continue()<CR>]])
-- map("n", "<leader>dr", [[<cmd>lua require"dap".repl.toggle()<CR>]])
-- map("n", "<leader>dK", [[<cmd>lua require"dap.ui.widgets".hover()<CR>]])
-- map("n", "<leader>dt", [[<cmd>lua require"dap".toggle_breakpoint()<CR>]])
-- map("n", "<leader>dso", [[<cmd>lua require"dap".step_over()<CR>]])
-- map("n", "<leader>dsi", [[<cmd>lua require"dap".step_into()<CR>]])
-- map("n", "<leader>dl", [[<cmd>lua require"dap".run_last()<CR>]])

