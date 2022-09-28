local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

lualine.setup({
  options = {
    disabled_filetypes = {'NvimTree'},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {},
    lualine_y = {'filetype'},
    lualine_z = {'progress'}
  },
})
