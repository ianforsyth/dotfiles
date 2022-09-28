local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
  return
end

vim.api.nvim_create_user_command("Gref", ".GBrowse", {}) -- Default :GBrowse to go to current line
vim.api.nvim_create_user_command("Gref", "'<,'>GBrowse", { range = true})
vim.api.nvim_create_user_command("Gblame", "Git blame", {})

gitsigns.setup()

