local status_ok, comment = pcall(require, "Comment")
if not status_ok then
  return
end

require('ts_context_commentstring').setup {
  enable_autocmd = false,
}
require('Comment').setup {
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
}
