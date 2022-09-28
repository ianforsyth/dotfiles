local status_ok, possession = pcall(require, "possession")
if not status_ok then
	return
end

possession.setup({
  silent = true,
  autosave = {
    current = true,
  },
  commands = {
    close = 'SClose',
    delete = 'SDelete',
    list = 'SList',
    load = 'SLoad',
    save = 'SSave',
    show = 'SShow',
  },
  plugins = {
    delete_hidden_buffers = false,
    close_windows = false,
    delete_buffers = true,
  },
})
