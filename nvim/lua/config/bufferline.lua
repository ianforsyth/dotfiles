local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

bufferline.setup({
  options = {
    indicator = {
      style = 'underline',
    },
    show_buffer_close_icons = false,
    always_show_bufferline = true,
    offsets = {
      {
        filetype = "NvimTree",
        text = function()
          return "Project: " .. capitalize(vim.fn.fnamemodify(vim.fn.getcwd(), ':t'))
        end,
        highlight = "Directory",
      }
    }
  }
})
