local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

nvim_tree.setup({
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
  },
  view = {
    hide_root_folder = true
  }
})
