local status_ok, workspaces = pcall(require, "workspaces")
if not status_ok then
	return
end

local session_exists = function()
   local f=io.open(".session.vim","r")
   if f~=nil then io.close(f) return true else return false end
end

local set_working_directory = function()
  vim.cmd('cd '..vim.fn.expand('%h')) -- Sets the working directory to whatever nvim was called on
end

local load_session = function()
  os.execute('grep -v "argadd" .session.vim > .tmp_session.vim') -- Removing the launch argument to prevent an extra buffer
  os.execute('mv .tmp_session.vim .session.vim')
  vim.cmd('source .session.vim')
end

local save_session = function ()
  if session_exists() then
    vim.cmd('NvimTreeClose') -- NvimTree messes up saved buffers so just close it
    vim.cmd('silent mksession! .session.vim')
  end
  vim.cmd('silent bufdo bw') -- Close all currently open buffers
end

local create_or_load_session = function()
  if session_exists() then
    load_session()
  else
    save_session()
  end
end

vim.api.nvim_create_autocmd({"VimEnter"}, {
  pattern = {"*"},
  callback = function ()
    set_working_directory()
    if session_exists() then
      load_session()
    end
  end,
})

vim.api.nvim_create_autocmd({"VimLeavePre"}, {
  pattern = {"*"},
  callback = save_session,
})

workspaces.setup({
  hooks = {
    open_pre = save_session,
    open = create_or_load_session,
  }
})
