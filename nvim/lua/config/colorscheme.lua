vim.o.background = "dark" -- or "light" for light mode

local colorscheme = "gruvbox"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

vim.cmd [[highlight EndOfBuffer guifg=bg]] -- Gets rid of tildes at the bottom of files
vim.cmd [[highlight NvimTreeNormal guibg=#1F1F1F]] -- Slightly darker background for file explorer
vim.cmd [[highlight VertSplit guifg=bg]] -- Don't show the vertical split line
