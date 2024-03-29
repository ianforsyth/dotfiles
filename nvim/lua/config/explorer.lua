-- local status_ok, nvim_tree = pcall(require, "nvim-tree")
-- if not status_ok then
--   return
-- end

vim.g["NERDTreeMinimalUI"] = 1
vim.g["NERDTreeChDirMode"] = 2
vim.g["NERDTreeShowHidden"] = 1

-- let g:NERDTreeMinimalUI = 1
-- let g:NERDTreeDirArrows = 1

-- nvim_tree.setup({
--   sync_root_with_cwd = true,
--   update_focused_file = {
--     enable = true,
--   },
--   view = {
--     hide_root_folder = true
--   }
-- })
